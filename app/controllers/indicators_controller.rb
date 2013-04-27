class IndicatorsController < ApplicationController

  hobo_model_controller

  auto_actions :all

  def update
    hobo_update do
      redirect_to this.objective.area.hoshin if valid? && !request.xhr?
    end
  end
end
