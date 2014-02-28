class ObjectivesController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => :index

  auto_actions_for :area, [:new, :create]
  
  include RestController
  
  
  def create
    obj = params["objective"]
    select_responsible(obj)
    hobo_create
  end
  
  def update
    obj = params["objective"]
    select_responsible(obj)
    hobo_update do
      redirect_to this.area.hoshin if valid? && !request.xhr?
    end
  end

end
