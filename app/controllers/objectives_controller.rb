class ObjectivesController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => :index

  auto_actions_for :area, [:new, :create]
  
  cache_sweeper :objectives_sweeper
  
  web_method :form
  
  
  include RestController
  
  def_param_group :objective do
    param :name, String
    param :description, String
  end
  
  api :GET, '/objectives/:id', 'Get an objective'
  def show
    hobo_show
  end
  
  def create
    obj = params["objective"]
    select_responsible(obj)
    hobo_create do
      redirect_to this.area.hoshin if valid? && !request.xhr?
    end
    log_event("Create objective", {objid: @this.id, name: @this.name})
  end
  
  api :POST, '/areas/:area_id/objectives', 'Create an objective for the given area'
  param_group :objective
  def create_for_area
    hobo_create_for :area do
      redirect_to this.area.hoshin if valid? && !request.xhr?
    end
    log_event("Create objective", {objid: @this.id, name: @this.name})
  end
  
  api :DELETE, '/objectives/:id', 'Delete an objective'
  param_group :objective
  def destroy
    hobo_destroy
    log_event("Delete objective", {objid: @this.id, name: @this.name})
  end
  
  api :PUT, '/objectives/:id', 'Update an objective'
  param_group :objective
  def update
    obj = params["objective"]
    select_responsible(obj)
    hobo_update do
      log_event("Update objective", {objid: @this.id, name: @this.name})
      redirect_to this.area.hoshin if valid? && !request.xhr?
    end
  end
  
  def form
    if (params[:id]) 
      @this = find_instance
    else
      @this = Objective.new
      @this.company_id = params[:company_id]
      @this.hoshin_id = params[:hoshin_id]
      @this.area_id = params[:area_id]
    end
  end

end
