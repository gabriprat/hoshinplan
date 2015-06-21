class ObjectivesController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => :index

  auto_actions_for :area, [:new, :create]
  
  cache_sweeper :objectives_sweeper
  
  web_method :form
  
  
  include RestController
  
  
  def create
    obj = params["objective"]
    select_responsible(obj)
    hobo_create do
      redirect_to this.area.hoshin if valid? && !request.xhr?
    end
    log_event("Create objective", {objid: @this.id, name: @this.name})
  end
  
  def create_for_area
    hobo_create_for :area do
      redirect_to this.area.hoshin if valid? && !request.xhr?
    end
    log_event("Create objective", {objid: @this.id, name: @this.name})
  end
  
  def destroy
    hobo_destroy
    log_event("Delete objective", {objid: @this.id, name: @this.name})
  end
  
  def update
    obj = params["objective"]
    select_responsible(obj)
    hobo_update do
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
