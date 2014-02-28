class IndicatorsController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => :index
  
  auto_actions_for :objective, [:index, :new, :create]
  
  show_action :history
  
  include RestController
  
  
  def update
    obj = params["indicator"]
    select_responsible(obj)
    hobo_update do
      redirect_to this.objective.area.hoshin if valid? && !request.xhr?
    end
  end
  
  def create
    obj = params["indicator"]
    select_responsible(obj)
    hobo_create
  end
  
  def history
      @this = Indicator.includes(:indicator_histories).find(params[:id])
      if request.xhr?
        hobo_ajax_response
      else
        respond_with(@this)
      end
  end
end
