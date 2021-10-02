class TasksController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => [:index, :new]

  auto_actions_for :objective, [:index, :new, :create]
  
  cache_sweeper :tasks_sweeper
    
  web_method :form

  include RestController
  
  def_param_group :task do
    param :id, :number, only_in: :response
    param :name, String, action_aware: true, required: true
    param :original_deadline, Date, only_in: :response
    param :created_at, Date, only_in: :response
    param :updated_at, Date, only_in: :response
    param :tsk_pos, :number, 'Used to sort the tasks in the hoshin view'
    param :lane_pos, :number, 'Used to sort the tasks in the kanban view'
    param :hoshin_id, :number, 'The id of the area this task belongs to', only_in: :response
    param :area_id, :number, 'The id of the area this task belongs to', only_in: :response
    param :company_id, :number, 'The id of the company this task belongs to', only_in: :response
    param :creator_id, :number, 'The id of the user that created this task', only_in: :response
    param :objective_id, :number, 'The id of the objective this task belongs to'
    param :responsible_id, :number, 'The id of the user that is responsible for this task'
    param :description, String
    param :deadline, Date
    param :show_on_parent, :boolean, 'Show this task in the parent Hoshin'
    param :parent_objective_id, :number, 'The id of the parent objective of the objective this task belongs to', only_in: :response
    param :parent_area_id, :number, 'The id of the area of the parent objective of the objective this task belongs to', only_in: :response
    param :reminder, :boolean, 'Send email reminders to the owner when the deadline comes'
    param :feeling, %w[smile wondering sad], 'How you are feeling about completing this task as planned'
    param :status, %w[backlog active completed discarded deleted]
    param :deleted_at, Date, 'The date when this task was deleted', only_in: :response
  end
  
  api :GET, '/tasks/:id', 'Get a task'
  example %q(curl "https://www.hoshinplan.com/tasks/45544?app_key=<APP_KEY>&timestamp=<TIMESTAMP>&signature=<SIGNATURE>" \
-H "Accept: application/json"


Response:
{
    "id": 45544,
    "name": "My task",
    "description": "This is my task created through the API",
    "deadline": "2021-01-03",
    "original_deadline": "2021-01-03",
    "created_at": "2010-10-02T09:47:59.186Z",
    "updated_at": "2010-10-02T10:33:42.326Z",
    "objective_id": 9400,
    "status": "backlog",
    "key_timestamp": null,
    "tsk_pos": 9,
    "area_id": 448231,
    "show_on_parent": null,
    "responsible_id": 253123,
    "company_id": 120,
    "reminder": true,
    "creator_id": null,
    "hoshin_id": 1545,
    "lane_pos": 0,
    "parent_area_id": null,
    "parent_objective_id": null,
    "feeling": "wondering"
})
  returns :task, code: :ok
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
      if obj[:status].present? && obj[:status] == 'active'
        self.this.lifecycle.to_active!(current_user)
      end
      if obj[:status].present? && current_user.initial_task_state != obj[:status]
        current_user.initial_task_state = obj[:status]
        current_user.save
      end
      respond_to do |format|
        format.html {
          redirect_to this.objective.area.hoshin if valid? && !request.xhr?
        }
        format.json {
          render :json => self.this.to_json, :status => :created
        }
        format.xml {
          render :xml => self.this.to_xml, :status => :created
        }
      end
    end
    log_event("Create task", {objid: @this.id, name: @this.name})
  end
  
  api :POST, '/objectives/:objective_id/tasks', 'Create a task for the given objective'
  param_group :task, :as => :create
  formats ['json', 'xml']
  example %q(curl -X POST "https://www.hoshinplan.com/objectives/23423/tasks?app_key=<APP_KEY>&timestamp=<TIMESTAMP>&signature=<SIGNATURE>" \
-H "Content-Type: application/json" \
-H "Accept: application/json" \
-d '{
  "name": "My new task",
  "description": "This is my task created through the API",
  "responsible_id": 213312,
  "status": "active"
}')
  returns :task, code: :created, desc: 'The newly created task'
  def create_for_objective
    delocalize_config = { deadline: :date }
    obj = params["task"]
    obj.delocalize(delocalize_config)
    select_responsible(obj)
    hobo_create_for :objective do
      if obj[:status].present? && obj[:status] == 'active'
        self.this.lifecycle.to_active!(current_user)
      end
      if obj[:status].present? && current_user.initial_task_state != obj[:status]
        current_user.initial_task_state = obj[:status]
        current_user.save
      end
      respond_to do |format|
        format.html {
          redirect_to this.objective.area.hoshin if valid? && !request.xhr?
        }
        format.json {
          render :json => self.this.to_json, :status => :created
        }
        format.xml {
          render :xml => self.this.to_xml, :status => :created
        }
      end
    end
    log_event("Create task", {objid: @this.id, name: @this.name})
  end
  
  api :DELETE, '/tasks/:id', 'Delete a task'
  example %q(curl -X DELETE "https://www.hoshinplan.com/tasks/45544?app_key=<APP_KEY>&timestamp=<TIMESTAMP>&signature=<SIGNATURE>" \
-H "Accept: application/json")
  returns nil, code: :no_content
  def destroy
    hobo_destroy do
      respond_to do |format|
        format.html {
          destroy_response
        }
        format.json {
          render nothing: true, status: :no_content
        }
        format.xml {
          render nothing: true, status: :no_content
        }
      end
    end
    log_event("Delete task", {objid: @this.id, name: @this.name})
  end

  def edit
    self.this = find_instance_with_deleted
    hobo_edit
  end
  
  api :PUT, '/tasks/:id', 'Update a task'
  param_group :task
  formats ['json', 'xml']
  example %q(curl -X PUT "https://www.hoshinplan.com/tasks/45544?app_key=<APP_KEY>&timestamp=<TIMESTAMP>&signature=<SIGNATURE>" \
-H "Content-Type: application/json" \
-H "Accept: application/json" \
-d '{
  "status": "completed"
}')
  returns :task, code: :ok, desc: 'The updated task'
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
      respond_to do |format|
        format.html {
          redirect_to this.objective.area.hoshin if valid? && !request.xhr?
        }
        format.json {
          render :json => self.this.to_json, :status => :ok
        }
        format.xml {
          render :xml => self.this.to_xml, :status => :ok
        }
      end
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
