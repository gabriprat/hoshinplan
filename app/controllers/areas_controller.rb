class AreasController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => [:new]
  
  show_action :charts
  
  include RestController
  
  cache_sweeper :areas_sweeper
  
  def charts
    @this = Area.includes(:indicators, {:indicators => :indicator_histories})
      .where(:id => params[:id], :indicators => {:show_on_charts => true}).order('indicators.ind_pos').references(:indicators).first
    hobo_show
  end
  
end
