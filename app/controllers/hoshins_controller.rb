class HoshinsController < ApplicationController

  hobo_model_controller

  auto_actions :all, :lifecycle, :except => [:index]
  
  auto_actions_for :company, [:new, :create]
  
  show_action :health, :kanban, :charts, :map
  
  web_method :kanban_update
  
  include RestController
  
  cache_sweeper :hoshins_sweeper
  
  def create
    if params["new-company-name"]
      company = Company.new
      company.name = params["new-company-name"]
      company.save!
      params["hoshin"]["company_id"] = company.id
    end
    hobo_create
    log_event("Create hoshin", {objid: @this.id, name: @this.name})
  end
  
  def destroy
    hobo_destroy
    log_event("Delete hoshin", {objid: @this.id, name: @this.name})
  end
  
  def create_for_company
    hobo_create
    log_event("Create hoshin", {objid: @this.id, name: @this.name})
  end
  
  def update
    begin
      hobo_update
    rescue RuntimeError
      #ignore "No update specified in params" errors
    end
    log_event("Update hoshin", {objid: @this.id, name: @this.name})
  end
  
  def show
    if request.xhr?
      hobo_ajax_response
    else
      hobo_show do |format|
            format.json { hobo_show }
            format.xml { hobo_show }
            format.html {
              current_user.all_companies
              if this.hoshins_count > 0
                ActiveRecord::Associations::Preloader.new.preload(self.this, 
                [:company, {:areas => [:objectives, :indicators, :tasks, :child_tasks, :child_indicators]}, :goals])
              else
                ActiveRecord::Associations::Preloader.new.preload(self.this, 
                [:company, {:areas => [:objectives, :indicators, :tasks]}, :goals])
              end
              Company.current_company = self.this.company
              hobo_show
            }
      end
    end
  end
  
  def health
    if request.xhr?
      hobo_ajax_response
    else
      hobo_show
    end
  end
  
  def charts
    @this = Hoshin.where(id: params[:id]).includes(:areas).first
    hobo_show
  end
  
  def kanban_update    
    task = Task.find(params[:item_id])
    state = params[:lane_id]
    position = params[:item_position].to_i + 1
    task.insert_at(position)
    task.lifecycle.send("to_" + state + "!", current_user)
    task.save!
    render :json => { result: :success }
  end
  
  def kanban
    @this = find_instance
    @lanes = Task::Lifecycle.states.keys
    if request.xhr?
      hobo_ajax_response
    end
  end
  
  def map
    raise Hobo::PermissionDeniedError unless Feature.enabled? :map
    @this = find_instance
    @lanes = Task::Lifecycle.states.keys
    @objectives = Objective.joins(:area).where( 
        Task.unscoped.where(
          Task.arel_table[:objective_id].eq(Objective.arel_table[:id])
            .and(Task.arel_table[:hoshin_id].eq(@this.id))
        ).exists
      ).references(:area).order("areas.id, obj_pos")
    if request.xhr?
      hobo_ajax_response
    end
  end

end
