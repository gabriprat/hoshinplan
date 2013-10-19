class UserCompaniesController < ApplicationController

  hobo_model_controller

  auto_actions :all, :lifecycle, :except => :index
  
  def destroy
    hobo_destroy do
      redirect_to this.company, :action => :edit if valid? && !request.xhr?
    end
  end

end
