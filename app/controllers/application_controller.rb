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
  
  rescue_from Timeout::Error, :backtrace => true do |exception|
    NewRelic::Agent.instance.error_collector.notice_error exception,
      uri: request.path,
      referer: request.referer,
      request_params: request.params
      
      error = {message:exception.message}
      error[:type] = exception.class.name.split('::').last || ''
      error[:code] = :service_unavailable
      error[:code] = exception.code if exception.respond_to?(:code) 
      error[:status] = :service_unavailable
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
  
  protect_from_forgery except: :omniauth_callback
  
  respond_to :html, :json, :xml
    
  before_filter :login_from_cookie
   
  before_filter :authenticate_client_app

  before_filter :my_login_required,  :except => [:login, :sso_login, :signup, :activate,
         :do_activate, :do_signup, :forgot_password, :reset_password,
         :do_reset_password, :mail_preview, :failure, :activate_from_email, :page]
        
  around_filter :set_user_time_zone,  :except => [:activate_from_email, :activate]
         
         around_filter :scope_current_user,  :except => [:activate_from_email, :activate]

             def scope_current_user
               ::NewRelic::Agent.add_custom_parameters({ http_referer: request.env["HTTP_REFERER"] }) unless request.nil?
               if defined?("logged_in?")
                 User.current_id = logged_in? ? current_user.id : nil
                 User.current_user = current_user
                 if current_user.respond_to?('last_seen_at') && (current_user.last_seen_at.nil? || current_user.last_seen_at < Date.today)
                   current_user.last_seen_at = Date.today
                   people_set
                   begin
                   current_user.save!
                   rescue ActiveRecord::RecordInvalid => invalid
                      fail invalid, invalid.message.to_s + ' Details: ' + invalid.record.errors.to_yaml
                    end
                 end
               end
               Rails.logger.debug "Scoping current user (" + User.current_id.to_s + ")"
               ::NewRelic::Agent.add_custom_parameters({ user_id: User.current_id }) unless User.current_id.nil?
               if request.method == 'POST' && self.respond_to?("model") && model && params[model.model_name.singular]
                   params[:company_id] ||= params[model.model_name.singular]["company_id"] 
               end               
               if self.respond_to?("model") && (!params[:id].nil? || !params[:company_id].nil? || params[:area] && !params[:area][:hoshin_id].nil?)
                 inst = User.current_user if self.is_a?(UsersController)
                 inst = model.find(params[:id]) if inst.nil? && !params[:id].nil?    
                 inst = Company.find(params[:company_id]) unless (inst || params[:company_id].nil?)
                 inst = Hoshin.find(params[:area][:hoshin_id]) unless inst
                 Rails.logger.debug inst.to_yaml
                 if inst.respond_to?(:company_id)
                   Company.current_id = inst.company_id
                   Company.current_company = Company.find(inst.company_id)
                 elsif inst.is_a? Company
                   Company.current_id = inst.id
                   Company.current_company = inst
                 end
               end
               Rails.logger.debug "Scoping current company (" + Company.current_id.to_s + ")"
               ::NewRelic::Agent.add_custom_parameters({ user_id: User.current_id }) unless User.current_id.nil?
               yield
               #rescue ActiveRecord::RecordInvalid => invalid
                # fail invalid, invalid.message.to_s + ' Details: ' + invalid.record.errors.to_yaml
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
    begin
      I18n.locale = params[:locale] || extract_locale_from_subdomain || user_locale || header_locale || I18n.default_locale
      logger.debug locale.to_yaml
    rescue I18n::InvalidLocale
      flash[:error] =  t("errors.invalid_locale", :default => "Invalid locale.")
    end
  end
  
  def header_locale
    http_accept_language.compatible_language_from(I18n.available_locales)
  end
  
  def user_locale
    current_user.language.to_s if (!current_user.nil? && current_user.respond_to?('language'))
  end
  
  # We provide our own method to call the Hobo helper here, so we can check the 
  # User count. 
  def my_login_required
    #return false if !defined?(logged_in)
    return true if logged_in?
    session[:return_to] = request.url
    redirect_to "/login"
    return false 
  end
  
    private
    
    def set_user_time_zone
      @cookie_time_zone = cookies[:tz]
      old_time_zone = Time.zone
      Time.zone = current_user.timezone if self.respond_to?("logged_in?") && logged_in?
      yield
    ensure
      Time.zone = old_time_zone
    end
    
    def authenticate_client_app
      return unless request.format && (request.format.json? || request.format.xml?)
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

  
  def select_responsible(obj)
    if (obj["responsible_id"].nil? && !obj["responsible"].nil?) 
      r = Regexp.new(/\(([a-zA-Z0-9\._%+-]+@[a-zA-Z0-9\.-]+\.[a-zA-Z]+)\)/)     
      email = obj["responsible"].scan(r).last
      if (!email.nil?)
        user = User.find_by_email_address(email)
        if (!user.nil?)
          obj["responsible_id"] = user.id
          obj.delete("responsible")
        end
      end
    end
  end
  
  def people_set
    Mp.people_set(current_user, request.remote_ip)
  end
  
  #Log a new Mixpanel event
  #event: name of event
  #opts: Properties defined for this event only.
  def log_event(event, opts = {}, perma_opts = {})
    opts[:url] =  url_for @this.hoshin if @this.respond_to? 'hoshin'
    Mp.log_event(event, current_user, request.remote_ip, opts)
  end

  #Log a new Mixpanel funnel step
  #funnel_name: what it says on the tin
  #step_number: 1, 2... etc.  Must be followed in order.  Mixpanel calls this "step".
  #step_name: String describing what user did to advance to this step...
  #           Mixpanel calls this "goal", for some reason.  Name must always be the
  #           same for a particular funnel and step number.
  #opts:      Properties defined for this event only.
  def log_funnel(funnel_name, step_number, step_name, opts = {})
   Mp.log_funnel(funnel_name, step_number, step_name, current_user, request.remote_ip, opts)
  end

  
  
  