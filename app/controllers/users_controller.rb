class UsersController < ApplicationController
  
  hobo_user_controller  
  
  auto_actions :all, :lifecycle, :except => :index
  
  show_action :dashboard, :tutorial, :pending, :unsubscribe, :kanban
    
  # Allow only the omniauth_callback action to skip the condition that
  # we're logged in. my_login_required is defined in application_controller.rb.
  skip_before_filter :my_login_required, :only => :omniauth_callback
  
  after_filter :update_data, :only => :omniauth_callback
  
  before_filter :collect_azure_attributes, :only => :omniauth_callback
      
  include HoboOmniauth::Controller
  
  include RestController
  
  def collect_azure_attributes
    if request.env["omniauth.auth"]["info"] && request.env["omniauth.auth"]["info"]["email"].nil?
      extra = request.env["omniauth.auth"].extra._?.raw_info.to_h
      request.env["omniauth.auth"]["info"]["email"] ||= extra["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"][0]
      request.env["omniauth.auth"]["info"]["first_name"] ||= extra["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname"][0]
      request.env["omniauth.auth"]["info"]["last_name"] ||= extra["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname"][0]
      request.env["omniauth.auth"]["info"]["name"] ||= extra["http://schemas.microsoft.com/identity/claims/displayname"][0]
    end
  end
  
  def create_auth_cookie
    cookies[:auth_token] = { :value => "#{current_user.remember_token} #{current_user.class.name}",
                                   :expires => current_user.remember_token_expires_at, :domain => :all }
  end
  
  def accept_invitation
    begin
      transition_page_action :accept_invitation 
    rescue Hobo::PermissionDeniedError => e
      unless request.xhr? || this.lifecycle.valid_key? 
        render template: 'users/invalid_invitation_key'  
      else
        fail e
      end
    end
  end
  
  def do_accept_invitation
    do_transition_action :accept_invitation do
      if valid?
        self.current_user = model.find(params[:id])
        redirect_to home_page
      end
    end
  end
  
  def do_activate
    do_transition_action :activate do
      if valid?
        self.current_user = model.find(params[:id])
        redirect_to home_page
      end
    end
  end
  
  def do_resend_activation
    do_transition_action :resend_activation do
      flash.now[:notice] = I18n.translate('user.messages.activation_mail_resent')
      hobo_ajax_response
    end
  end
  
  def activate
    begin
      transition_page_action :activate 
    rescue Hobo::PermissionDeniedError => e
      unless request.xhr? || this.lifecycle.valid_key? 
        render template: 'users/invalid_activation_key'  
      else
        fail e
      end
    end
  end
  
  def admin_only
      render :text => "Permission Denied", :status => 403 unless current_user.administrator?
  end
  
  def dashboard
    redirect_to current_user
  end
  
  def show
    begin   
      ActiveRecord::Associations::Preloader.new.preload(self.this, 
        [:dashboard_tasks, :dashboard_indicators]) 
      raise Hobo::PermissionDeniedError if self.this.nil?
      self.this.all_active_user_companies_and_hoshins
      name = self.this.name.nil? ? self.this.email_address : self.this.name
      @page_title = I18n.translate('user.dashboard_for', :name => name, 
        :default => 'Dashboard for ' + name)     
      hobo_show
    rescue Hobo::PermissionDeniedError => e
      self.current_user = nil
      redirect_to "/login?force=true"
    end
  end
  
  def kanban
    @this = find_instance
    @lanes = Task::Lifecycle.states.keys
    if request.xhr?
      hobo_ajax_response
    end
  end
  
  def login
    unless params[:force] || request.post? && params[:login].nil?
      hobo_login do
        if performed?
          redirect_to home_page 
        else
          true #continue normal hobo_login behavior
        end
      end
    end
  end
    
  
  def pending
    begin
      current_user.all_companies
      self.this = User.includes({:user_companies => {:company => :active_hoshins}}).preload([:pending_tasks, :pending_indicators])
        .order('lower(companies.name) asc, lower(hoshins.name) asc').references(:company, :hoshin)
        .user_find(current_user, params[:id])
      ActiveRecord::Associations::Preloader.new.preload(self.this, [:pending_tasks, :pending_indicators])
      @page_title = I18n.translate('user.pending_actions_for', :name => self.this.name, 
        :default => 'Pending actions for ' + self.this.name)      
    rescue Hobo::PermissionDeniedError => e
      self.current_user = nil
      redirect_to "/login?force=true"
    end
  end
  
  def unsubscribe
    @this = find_instance
  end

  def tutorial
    @this = find_instance
  end
  
  def logout_and_return
    logout_current_user
    redirect_to params["return_url"]
  end
  
  # Normally, users should be created via the user lifecycle, except
  #  for the initial user created via the form on the front screen on
  #  first run.  This method creates the initial user.
  def create
    hobo_create do
      if valid?
        self.current_user = this
        flash[:notice] = t("hobo.messages.you_are_site_admin", :default=>"You are now the site administrator")
        redirect_to home_page
      end
    end
    people_set
  end
  
  def update
    ajax = request.xhr? || !(request.headers['HTTP_X_REQUESTED_WITH'] !~ /XMLHttpRequest/i)
    
    self.this = find_instance
    
    if self.this.timezone.nil? && !cookies[:tz].nil?
   	  zone = cookies[:tz]
   	  zone = Hoshinplan::Timezone.get(zone)
      self.this.timezone = zone.name unless zone.nil?
    end
    if params[:user] && params[:user][:preferred_view]
      ajax = true
    end
    if params[:tutorial_step] 
      step = params[:tutorial_step].to_i
      if step == 1
        self.this.tutorial_step << self.this.next_tutorial
      elsif step == -1
        self.this.tutorial_step.pop
      elsif step > 1
        self.this.tutorial_step = User.values_for_tutorial_step
      elsif step < -1
        self.this.tutorial_step = []
      end
      if !params[:user]
        params[:user] = {}
      end
      params[:user][:tutorial_step] = self.this.tutorial_step
      ajax = true
    end
    if params[:delete_image].present?
      self.this.image.clear
      self.this.save
      if ajax
        flash[:notice] = nil
        hobo_ajax_response
      else
        redirect_to current_user, :dgv => Time.now.to_i if valid?
      end
    else
      begin
        hobo_update do
          if ajax
            flash[:notice] = nil
            hobo_ajax_response
          else
            redirect_to current_user, :dgv => Time.now.to_i if valid?
          end
        end
      rescue Paperclip::Error => e
        if ajax
          render text: "Unrecognized image format", :status => 400
        else
          redirect_to current_user, :dgv => Time.now.to_i if valid?
        end
      end
    end
    people_set
  end
  
  def update_data
    auth = request.env["omniauth.auth"]
    provider = auth['provider']
    uid = auth['uid']
    email = auth['info']['email']
    firstName = auth['info']['firstName']
    lastName = auth['info']['lastName']
    firstName ||= auth['info']['first_name']
    lastName ||= auth['info']['last_name']
    current_user.delay.update_data_from_authorization(provider, uid, email, firstName, lastName, request.remote_ip, cookies[:tz], header_locale)
  end
  
  def signup
    self.this = User.new
    self.this.timezone = cookies[:tz]
    self.this.language = header_locale
    hobo_signup
  end
  
  def sign_in(user) 
    sign_user_in(user)
  end
  
  def sign_user_in(user, password=nil)
    params[:remember_me] = true
    if (password.nil?)
      super(user) {remember(user)}
    else
      super(user, password) {remember(user)}
    end
  end
  
  def remember(user)
    current_user.remember_me if user.account_active?
    create_auth_cookie if user.account_active?
    true
  end
  
  def omniauth
  end
end
