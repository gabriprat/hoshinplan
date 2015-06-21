class TasksController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => [:index, :new]

  auto_actions_for :objective, [:index, :new, :create]
  
  cache_sweeper :tasks_sweeper
    
  web_method :form
  
  include RestController
  
  def reorder_lane
    con  = ActiveRecord::Base.connection.raw_connection
    values = [params[:task_ordering]].concat(params[:task_ordering].split(","))
    bind = ""
    params[:task_ordering].split(",").each_with_index {|item,index|
      bind += "," unless bind.blank?
      bind += "$" + (index+2).to_s
    }
    sql = "UPDATE tasks set lane_pos = new_pos from (SELECT id, row_number() over (ORDER BY position(id::text in $1)) - 1 as new_pos FROM tasks where id in (#{bind})) as tsk where tasks.id = tsk.id"
    ret = con.exec(sql, values)
    Rails.logger.debug "==============" + sql + "\n" + values.to_s + ret.to_yaml
    render :js => 'true'
  end
  
  def create
    obj = params["task"]
    select_responsible(obj)
    hobo_create do
      redirect_to this.objective.area.hoshin if valid? && !request.xhr?
    end
    log_event("Create task", {objid: @this.id, name: @this.name})
  end
  
  def create_for_objective
    hobo_create_for :objective do
      redirect_to this.objective.area.hoshin if valid? && !request.xhr?
    end
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
