class IndicatorsController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => :index
  
  show_action :history
  
  include RestController
  
  
  def update
    hobo_update do
      redirect_to this.objective.area.hoshin if valid? && !request.xhr?
    end
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
