class TasksController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => [:index, :new]

  auto_actions_for :objective, [:index, :new, :create]
  
  cache_sweeper :tasks_sweeper
  
  show_action :form
  
  index_action :form
  
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

  def form
    if (params[:id]) 
      @this = find_instance
    else
      @this = Task.new
      @this.company_id = params[:company_id]
      @this.objective_id = params[:objective_id]
      @this.area_id = params[:area_id]
    end
  end
end
