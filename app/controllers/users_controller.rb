class UsersController < ApplicationController
  
  hobo_user_controller
  
  autocomplete
  
  show_action :dashboard
  
  index_action :suplist
  
  web_method :supplant
  
  # Allow only the omniauth_callback action to skip the condition that
  # we're logged in. my_login_required is defined in application_controller.rb.
  skip_before_filter :my_login_required, :only => :omniauth_callback
  
  after_filter :update_data, :only => :omniauth_callback
  
  auto_actions :all, :except => [ :index, :new, :create ]
  
  before_filter :admin_only, :only => [ :suplist, :supplant ]
  
  include HoboOmniauth::Controller
  
  include RestController
  
  def admin_only
      render :text => "Permission Denied", :status => 403 unless current_user.administrator?
  end
  
  def suplist
    users = model.all
    @this = { "guest" => 0 }
    users.each { |u| 
      @this[u.login.to_s] = u.id 
    }
  end
  
  def supplant
    self.current_user = find_instance
    redirect_to home_page
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
  
  def update_data
    auth = request.env["omniauth.auth"]
    authorization = Authorization.find_by_provider_and_uid(auth['provider'], auth['uid'])
    authorization ||= Authorization.find_by_email_address(auth['info']['email'])
    atts = authorization.attributes.slice(*model.accessible_attributes.to_a)
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
