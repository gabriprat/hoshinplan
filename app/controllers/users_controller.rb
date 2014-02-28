class UsersController < ApplicationController
  
  hobo_user_controller
    
  show_action :dashboard
  
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
    fail param.to_yaml
    hobo_update
  end
  
  def update_data
    auth = request.env["omniauth.auth"]
    authorization = Authorization.find_by_provider_and_uid(auth['provider'], auth['uid'])
    authorization ||= Authorization.find_by_email_address(auth['info']['email'])
    atts = authorization.attributes.slice(*model.accessible_attributes.to_a)
    # PATCH: InfoJobs Open Id returns only the family name as the name and the full name in nickname... Strange...
    if (current_user.email_address.split("@").last == "infojobs.net")
      atts['name'] = auth['info']['nickname']
    end
    atts.each { |k, v| 
      atts.delete(k) if !current_user.attributes[k].nil? && !current_user.attributes[k].empty? || v.nil?
    }
    current_user.attributes = atts
    if current_user.lifecycle.state.name == :invited
      current_user.lifecycle.activate!(current_user)
    end
    current_user.save!
  end
  
  def sign_in(user) 
    sign_user_in(user)
  end
  
  def dashboard 
    @this = find_instance
  end
  
end
