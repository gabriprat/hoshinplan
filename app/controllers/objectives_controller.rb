class ObjectivesController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => :index

  auto_actions_for :area, [:new, :create]
  
  def update
    hobo_update do
      redirect_to this.area.hoshin if valid? && !request.xhr?
    end
  end

end
