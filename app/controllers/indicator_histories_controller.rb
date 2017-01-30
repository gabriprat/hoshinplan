class IndicatorHistoriesController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => :index
  
  auto_actions_for :indicator, [:create]
  
  cache_sweeper :indicator_histories_sweeper
  
  include RestController
  
  def_param_group :indicator_history do
    param :day, Date
    param :value, :number
    param :goal, :number
    param :previous, :number
  end
  
  api :GET, '/indicator_histories/:id', 'Get an indicator historic value'
  def show
    hobo_show
  end
  
  api :PUT, '/indicator_histories/:id', 'Update an indicator historic value'
  param_group :indicator_history
  def update
    hobo_update
  end
  
  api :POST, '/indicator/:indicator_id/indicator_histories', 'Create an indicator historic value for the given indicator'
  param_group :indicator_history
  def create_for_indicator
    hobo_create_for :indicator
  end
  
  api :DELETE, '/indicator_histories/:id', 'Delete an indicator historic value'
  param_group :indicator_history
  def destroy
    inst = find_instance.indicator
    hobo_destroy do
      redirect_to inst, :action => :history if valid? && !request.xhr?
    end
  end

end
