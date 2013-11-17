class TasksController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => :index

  auto_actions_for :objective, [:new, :create]
  
  include RestController
  
  
  def update
    hobo_update do
      redirect_to this.objective.area.hoshin if valid? && !request.xhr?
    end
  end
  
end
