class IndicatorHistoriesController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => :index
  
  cache_sweeper :indicator_histories_sweeper
  
  include RestController
  
  def destroy
    inst = find_instance.indicator
    hobo_destroy do
      redirect_to inst, :action => :history if valid? && !request.xhr?
    end
  end

end
