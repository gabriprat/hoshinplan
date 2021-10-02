class IndicatorHistoriesController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => :index
  
  auto_actions_for :indicator, [:create]
  
  cache_sweeper :indicator_histories_sweeper
  
  include RestController
  
  def show
    hobo_show
  end

  def update
    hobo_update
  end

  def create_for_indicator
    hobo_create_for :indicator
  end

  def destroy
    inst = find_instance.indicator
    hobo_destroy do
      redirect_to inst, :action => :history if valid? && !request.xhr?
    end
  end

end
