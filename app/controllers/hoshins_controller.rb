class HoshinsController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => [:index]
  
  auto_actions_for :company, [:new, :create]
  
  show_action :health, :kanban
  
  web_method :kanban_update
  
  include RestController
  
  cache_sweeper :hoshins_sweeper
  
  def create
    if params["new-company-name"]
      company = Company.new
      company.name = params["new-company-name"]
      company.save!
      params["hoshin"]["company_id"] = company.id
    end
    hobo_create
  end
  
  def health
    @this = find_instance
  
  end
  
  def kanban_update    
    task = Task.find(params[:item_id])
    state = params[:lane_id]
    position = params[:item_position].to_i + 1
    task.insert_at(position)
    task.lifecycle.send("to_" + state + "!", current_user)
    task.save!
    render :json => { result: :success }
  end
  
  def kanban
    @this = find_instance
    @lanes = Task::Lifecycle.states.keys
  end

end
