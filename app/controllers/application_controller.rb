class ApplicationController < ActionController::Base
  
  helper CmsHelper

  rescue_from RuntimeError do |exception|
    error = {message:exception.message}
    error[:type] = exception.class.name.split('::').last || ''
    error[:code] = :internal_server_error
    error[:code] = exception.code if exception.respond_to?(:code) 
    error[:status] = :internal_server_error
    error[:status] = exception.status if exception.respond_to?(:status) 
    error[:stack_trace] = exception.backtrace if Rails.env.development? 
    respond_to do |format|
      format.html { raise exception }
      format.json { render :json => error, status: error[:status] }
      format.xml { render :xml => error, status: error[:status] }
    end
  end
  
  require 'time'
  
  TIMESTAMP_MAX_AGE_SEC = 300.freeze
  
  protect_from_forgery
  
  respond_to :html, :html, :xml
  
  before_filter :authenticate_client_app

  before_filter :my_login_required,  :except => [:index, :login, :signup, :activate,
         :do_activate, :do_signup, :forgot_password, :reset_password,
         :do_reset_password, :mail_preview]
         
         around_filter :scope_current_user  

             def scope_current_user
               Rails.logger.debug params.to_yaml
                 if !params[:id].nil? || !params[:company_id].nil? || params[:area] && !params[:area][:hoshin_id].nil?
                   inst = model.unscoped.find(params[:id]) unless params[:id].nil?
                   inst = Company.unscoped.find(params[:company_id]) unless inst || params[:company_id].nil?
                   inst = Hoshin.unscoped.find(params[:area][:hoshin_id]) unless inst
                   Rails.logger.debug inst.to_yaml
                   if inst.respond_to?(:company_id)
                     Company.current_id = inst.company_id
                   elsif inst.is_a? Company
                     Company.current_id = inst.id
                   end
                 end
                 Rails.logger.debug "Scoping current company (" + Company.current_id.to_s + ")"
                 if defined?("logged_in?")
                   User.current_id = logged_in? ? current_user.id : nil
                 end
                 Rails.logger.debug "Scoping current user (" + User.current_id.to_s + ")"
             yield
             ensure
                 #avoids issues when an exception is raised, to clear the current_id
                 User.current_id = nil   
                 Company.current_id = nil    
             end
             
  before_filter :is_pdf
  def is_pdf
    @pdf = request.original_url.split('?').first.ends_with?(".pdf")
  end
             
  before_filter :action_mailer_init
  
  def action_mailer_init
    ActionMailer::Base.default_url_options = {:host => request.host_with_port}
    ActionMailer::Base.default_url_options[:only_path] = false
  end
  
  before_filter :set_locale
 
 
  # Get locale code from request subdomain (like http://it.application.local:3000)
  # You have to put something like:
  #   127.0.0.1 gr.application.local
  # in your /etc/hosts file to try this out locally
  def extract_locale_from_subdomain
    parsed_locale = request.subdomains.first
    I18n.available_locales.include?(parsed_locale.to_sym) ? parsed_locale : nil if !parsed_locale.nil?
  end
  
  def set_locale
    I18n.locale = params[:locale] || extract_locale_from_subdomain || I18n.default_locale
  end
  
  
  # We provide our own method to call the Hobo helper here, so we can check the 
  # User count. 
  def my_login_required
    #return false if !defined?(logged_in)
    return true if logged_in?
    flash[:warning]='Please login to continue'
    session[:return_to] = request.url
    redirect_to "/auth/google_oauth2"
    return false 
     
  end
  
    private
    
    def authenticate_client_app
      return if (request.format.html? || request.xhr?)
      app_key = params[:app_key].presence
      raise Errors::SecurityError.new(1), "Client application key parameter (app_key) not provided." unless app_key
      t = Time.xmlschema(params[:timestamp].presence)
      raise Errors::SecurityError.new(2), "Timestamp parameter (timestamp) not provided." unless t
      n = Time.now
      raise Errors::SecurityError.new(3), "Timestamp in the future" if t > n
      raise Errors::SecurityError.new(4), "Timestamp too old." if (n - t) > TIMESTAMP_MAX_AGE_SEC
      path,notused,signature = request.fullpath.rpartition("&signature=")
      app = ClientApplication.unscoped.find_by_key(app_key)
      raise Errors::SecurityError.new(5), "No client application found with the given key." unless app
      signature2 = app.sign(path)
      raise Errors::SecurityError.new(6), "Invalid signature" unless signature == signature2
      ClientApplication.current_app = app
      self.current_user = app.user
      User.current_id = app.user.id
    end
  
end

 def login_required
    if session[:user]
      return true
    end
    flash[:warning]='Please login to continue'
    session[:return_to]=request.request_uri
    redirect_to "/auth/google_oauth2"
    return false 
  end
  
  