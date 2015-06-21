class GoalsController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => :index
  
  auto_actions_for :hoshin, [:new, :create]
  
  cache_sweeper :goals_sweeper

  include RestController
  
  def create_for_hoshin
    hobo_create_for :hoshin do
      redirect_to this.hoshin if valid? && !request.xhr?
    end
  end

end
