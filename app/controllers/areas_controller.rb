class AreasController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => [:new, :index]
  
  show_action :charts
  
  include RestController
  
  cache_sweeper :areas_sweeper
  
  def charts
    @this = Area.includes(:indicators, {:indicators => :indicator_histories})
      .where(:id => params[:id]).order('indicators.ind_pos').references(:indicators).first
    hobo_show
  end
  
end
