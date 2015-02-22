class TasksController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => [:index, :new]

  auto_actions_for :objective, [:index, :new, :create]
  
  cache_sweeper :tasks_sweeper
    
  web_method :form
  
  include RestController
  
  def create
    obj = params["task"]
    select_responsible(obj)
    hobo_create
    log_event("Create task", {objid: @this.id, name: @this.name})
  end
  
  def destroy
    hobo_destroy
    log_event("Delete task", {objid: @this.id, name: @this.name})
  end
  
  def update
    self.this = find_instance
    if (params[:task] && params[:task][:status]) 
      self.this.lifecycle.send("to_" + params[:task][:status] + "!", current_user)
      params[:task].delete(:status)
    end
    obj = params["task"]
    select_responsible(obj)
    hobo_update do
      redirect_to this.objective.area.hoshin if valid? && !request.xhr?
    end
    log_event("Update task", {objid: @this.id, name: @this.name})
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
