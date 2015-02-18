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
    hobo_create
    log_event("Create objective", {objid: @this.id, name: @this.name})
  end
  
  def update
    obj = params["objective"]
    select_responsible(obj)
    hobo_update do
      redirect_to this.area.hoshin if valid? && !request.xhr?
    end
  end
  
  def form
    @this = find_instance
  end

end
