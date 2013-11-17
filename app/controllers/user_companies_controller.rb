class UserCompaniesController < ApplicationController

  hobo_model_controller

  auto_actions :all, :lifecycle, :except => :index
  
  include RestController
  
  
  def destroy
    hobo_destroy do
      redirect_to this.company, :action => :edit if valid? && !request.xhr?
    end
  end

  def do_accept
    do_transition_action :accept, :redirect => find_instance.company
    
  end
end
