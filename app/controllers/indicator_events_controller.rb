class IndicatorEventsController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => [:new, :index]
  
  auto_actions_for :indicator, [:new, :create]
  
  include RestController
  
  
  def create_for_indicator
    hobo_create_for :indicator do
      redirect_to this.indicator, :action => :history if valid? && !request.xhr?
    end
    log_event("Create area", {objid: @this.id, name: @this.name})
  end
  
  def update
    hobo_update do
      redirect_to this.indicator, :action => :history if valid? && !request.xhr?
    end
  end
  
  def destroy
    hobo_destroy do
      redirect_to this.indicator, :action => :history if valid? && !request.xhr?
    end
  end
  
end
