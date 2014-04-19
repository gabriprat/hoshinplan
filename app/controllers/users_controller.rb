class UsersController < ApplicationController
  
  hobo_user_controller  
  
  show_action :dashboard, :tutorial
  
  # Allow only the omniauth_callback action to skip the condition that
  # we're logged in. my_login_required is defined in application_controller.rb.
  skip_before_filter :my_login_required, :only => :omniauth_callback
  
  after_filter :update_data, :only => :omniauth_callback
  
  auto_actions :all, :except => [ :index, :new, :create ]
    
  include HoboOmniauth::Controller
  
  include RestController
  
  def admin_only
      render :text => "Permission Denied", :status => 403 unless current_user.administrator?
  end
  
  def dashboard
    redirect_to current_user
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
  end
  
  def update
    ajax = request.xhr?
    @this = find_instance
    
    if @this.timezone.nil? && !cookies[:tz].nil?
   	  zone = cookies[:tz]
   	  zone = Hoshinplan::Timezone.get(zone)
      @this.timezone = zone.name unless zone.nil?
    end
    
    if params[:tutorial_step] 
      step = params[:tutorial_step].to_i
      if step == 1
        @this.tutorial_step << @this.next_tutorial
      elsif step == -1
        @this.tutorial_step.pop
      elsif step == 0
        logger.debug "sdfsañlkj dsaklfj añsklfdj alksdfj añlsk "
        @this.tutorial_step = User.values_for_tutorial_step
      end
      if !params[:user]
        params[:user] = {}
      end
      params[:user][:tutorial_step] = @this.tutorial_step
      ajax = true
    end
    hobo_update do
      if ajax
        hobo_ajax_response
      else
        redirect_to current_user, :dgv => Time.now.to_i if valid?
      end
    end
  end
  
  def update_data
    auth = request.env["omniauth.auth"]
    authorization = Authorization.find_by_provider_and_uid(auth['provider'], auth['uid'])
    authorization ||= Authorization.find_by_email_address(auth['info']['email'])
    atts = authorization.attributes.slice(*model.accessible_attributes.to_a)
    # PATCH: InfoJobs Open Id returns only the family name as the name and the full name in nickname... Strange...
    domain = current_user.email_address.split("@").last
    if (domain == "infojobs.net" || domain == "lectiva.com")
      atts['name'] = auth['info']['nickname']
    end
    atts.each { |k, v| 
      atts.delete(k) if !current_user.attributes[k].nil? && !current_user.attributes[k].empty? || v.nil?
    }
    begin
      current_user.attributes = atts
    rescue
      current_user.attributes = atts.delete('photo')
    end
    if current_user.lifecycle.state.name == :invited
      current_user.lifecycle.activate!(current_user)
    end
    if current_user.timezone.nil? && !cookies[:tz].nil?
   	  zone = cookies[:tz]
   	  zone = Hoshinplan::Timezone.get(zone)
      current_user.timezone = zone.name unless zone.nil?
    end
    current_user.save!
  end
  
  def sign_in(user) 
    sign_user_in(user)
  end
  
  def sign_user_in(user, password=nil)
    params[:remember_me] = true
    if (password.nil?)
      super(user)
    else
      super(user, password)
    end
    current_user.remember_me
    create_auth_cookie
  end
  
end
