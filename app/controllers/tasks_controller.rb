class TasksController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => [:index, :new]

  auto_actions_for :objective, [:index, :new, :create]
  
  cache_sweeper :tasks_sweeper
    
  web_method :form

  include RestController
  
  def_param_group :task do
    param :name, String
    param :description, String
    param :deadline, Date
    param :show_on_parent, :boolean, 'Show this indicator in the parent Hoshin'
    param :reminder, :boolean, 'Send email reminders to the owner when the next update date comes'
    param :feeling, [:smile, :wondering, :sad], 'How you are feeling about completing this task as planned'
  end
  
  api :GET, '/tasks/:id', 'Get a task'
  def show
    hobo_show
  end
  
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
    delocalize_config = { deadline: :date }
    obj = params["task"]
    obj.delocalize(delocalize_config)
    select_responsible(obj)
    hobo_create do
      if params[:status].present? && params[:status] == 'active'
        self.this.lifecycle.to_active!(current_user)
      end
      if params[:status].present? && current_user.initial_task_state != params[:status]
        current_user.initial_task_state = params[:status]
        current_user.save
      end
      redirect_to this.objective.area.hoshin if valid? && !request.xhr?
    end
    log_event("Create task", {objid: @this.id, name: @this.name})
  end
  
  api :POST, '/objectives/:objective_id/tasks', 'Create a task for the given objective'
  param_group :task
  def create_for_objective
    hobo_create_for :objective do
      if params[:status].present? && params[:status] == 'active'
        self.this.lifecycle.to_active!(current_user)
      end
      if params[:status].present? && current_user.initial_task_state != params[:status]
        current_user.initial_task_state = params[:status]
        current_user.save
      end
      redirect_to this.objective.area.hoshin if valid? && !request.xhr?
    end
    log_event("Create task", {objid: @this.id, name: @this.name})
  end
  
  api :DELETE, '/tasks/:id', 'Delete a task'
  param_group :task
  def destroy
    hobo_destroy
    log_event("Delete task", {objid: @this.id, name: @this.name})
  end

  def edit
    self.this = find_instance_with_deleted
    hobo_edit
  end
  
  api :PUT, '/tasks/:id', 'Update a task'
  param_group :task
  def update
    delocalize_config = { deadline: :date }
    self.this = find_instance
    if (params[:task] && params[:task][:status].present?)
      self.this.lifecycle.send("to_" + params[:task][:status] + "!", current_user)
      params[:task].delete(:status)
    end
    obj = params["task"]
    obj.delocalize(delocalize_config)
    select_responsible(obj)
    hobo_update do
      redirect_to this.objective.area.hoshin if valid? && !request.xhr?
    end
    log_event("Update task", {objid: @this.id, name: @this.name})
  end

  def form
    if (params[:id]) 
      @this = Task.includes(:hoshin).where({id: params[:id]}).first
      Hoshin.current_hoshin = @this.hoshin
    else
      @this = Task.new
      @this.company_id = params[:company_id]
      @this.hoshin_id = params[:hoshin_id]
      @this.objective_id = params[:objective_id]
      @this.area_id = params[:area_id]
    end
  end

end
