class GoalsController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => :index
  
  auto_actions_for :hoshin, [:new, :create]
  web_method :form
  
  
  cache_sweeper :goals_sweeper

  include RestController
  
  def create
    hobo_create do
      redirect_to this.hoshin if valid? && !request.xhr?
    end
  end
  
  def update
    hobo_update do
      redirect_to this.hoshin if valid? && !request.xhr?
    end
  end
  
  def create_for_hoshin
    hobo_create_for :hoshin do
      redirect_to this.hoshin if valid? && !request.xhr?
    end
  end


  def form
    if (params[:id])
      @this = find_instance
    else
      @this = Goal.new
      @this.company_id = params[:company_id]
      @this.hoshin_id = params[:hoshin_id]
    end
  end


end
