class UserCompaniesController < ApplicationController

  hobo_model_controller

  auto_actions :all, :lifecycle, :except => :index
  
  include RestController
  
  def permission_denied(error)
    @title = t "user_company.that_operation_is"
    
    if find_instance.user_id != current_user.id
      redirect_to "/users/logout_and_return?return_url=" + request.fullpath
    else
      @message = t "user_company.the_provided_key"
      super
    end
  end
  
  def destroy
    hobo_destroy do
      redirect_to this.company, :action => :edit if valid? && !request.xhr?
    end
  end

  def do_accept
    do_transition_action :accept, :redirect => "/invitation-accepted"
  end
end
