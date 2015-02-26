class HoshinsController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => [:index]
  
  auto_actions_for :company, [:new, :create]
  
  show_action :health, :kanban, :charts
  
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
    log_event("Create hoshin", {objid: @this.id, name: @this.name})
  end
  
  def destroy
    hobo_destroy
    log_event("Delete hoshin", {objid: @this.id, name: @this.name})
  end
  
  def create_for_company
    hobo_create
    log_event("Create hoshin", {objid: @this.id, name: @this.name})
  end
  
  def update
    hobo_update
    log_event("Update hoshin", {objid: @this.id, name: @this.name})
  end
  
  def show
    if request.xhr?
      hobo_ajax_response
    else
      hobo_show do |format|
            format.json { hobo_show }
            format.xml { hobo_show }
            format.html {
              self.this = Hoshin.includes([:company, {:areas => [:objectives, :indicators, :tasks]}, :goals])
                .user_find(current_user, params[:id]) 
              hobo_show
            }
      end
    end 
    
    #if we were sure no caches would be hit we could use the above statement and avoid 9 queries!!
    #self.this = Hoshin.includes([:areas, :goals]).user_find(current_user, params[:id])
    
  end
  
  def health
    hobo_show
  end
  
  def charts
    @this = Hoshin.where(id: params[:id]).includes(:areas).first
    hobo_show
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
