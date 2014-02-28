class TasksController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => [:index, :new]

  auto_actions_for :objective, [:index, :new, :create]
  
  include RestController
  
  def create
    obj = params["task"]
    select_responsible(obj)
    hobo_create
  end
  
  def update
    obj = params["task"]
    select_responsible(obj)
    hobo_update do
      redirect_to this.objective.area.hoshin if valid? && !request.xhr?
    end
  end

end
