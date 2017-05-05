class AreasController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => [:new, :index]
  
  auto_actions_for :hoshin, [:new, :create]
  
  show_action :charts
  web_method :form
  
  
  include RestController
  
  cache_sweeper :areas_sweeper
  
  def_param_group :area do
    param :name, String
    param :description, String
  end
  
  def create
    hobo_create do
      redirect_to this.hoshin if valid? && !request.xhr?
    end
    log_event("Create area", {objid: @this.id, name: @this.name})
  end
  
  api :POST, '/hoshins/:hoshin_id/areas', 'Create an area for the given Hoshin'
  param_group :area
  def create_for_hoshin
    hobo_create_for :hoshin do
      redirect_to this.hoshin if valid? && !request.xhr?
    end
    log_event("Create area", {objid: @this.id, name: @this.name})
  end
  
  api :PUT, '/areas/:id', 'Edit an area'
  param_group :area
  def update
    hobo_update do
      redirect_to this.hoshin if valid? && !request.xhr?
    end
  end
  
  api :DELETE, '/areas/:id', 'Delete an area'
  param_group :area
  def destroy
    hobo_destroy
    log_event("Delete area", {objid: @this.id, name: @this.name})
  end
  
  api :GET, '/areas/:id', 'Get an area'
  def show
    hobo_show
  end
  
  def charts
    @this = Area.includes(:indicators, {:indicators => :indicator_histories})
      .where(:id => params[:id]).order('indicators.ind_pos, indicator_histories.day').references(:indicators).first
    Hoshin.current_hoshin = @this.hoshin
    hobo_show
  end

  def form
    if (params[:id])
      @this = find_instance
    else
      @this = Area.new
      @this.company_id = params[:company_id]
      @this.hoshin_id = params[:hoshin_id]
    end
  end



end
