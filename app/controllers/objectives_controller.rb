class ObjectivesController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => :index

  auto_actions_for :area, [:new, :create]
  
  cache_sweeper :objectives_sweeper
  
  web_method :form
  
  
  include RestController
  
  def_param_group :objective do
    param :id, :number, only_in: :response
    param :name, String, action_aware: true, required: true
    param :description, String
    param :created_at, Date, only_in: :response
    param :updated_at, Date, only_in: :response
    param :hoshin_id, :number, 'The id of the area this objective belongs to', only_in: :response
    param :area_id, :number, 'The id of the area this objective belongs to', only_in: :response
    param :company_id, :number, 'The id of the company this objective belongs to', only_in: :response
    param :obj_pos, :number, 'Used to sort the objectives in the hoshin view'
    param :parent_id, :number, 'The id of the parent objective in the parent hoshin'
    param :responsible_id, :number, 'The id of the user that is responsible for this objective'
    param :creator_id, :number, 'The id of the user that created this objective', only_in: :response
    param :neglected, :boolean, 'True if this objective has indicators below 100% and does not have any active tasks' , only_in: :response
    param :blind, :boolean, 'True if this objective does not have any indicators' , only_in: :response
    param :deleted_at, Date, 'The date when this objective was deleted', only_in: :response
  end
  
  api :GET, '/objectives/:id', 'Get an objective'
  example %q(curl "https://www.hoshinplan.com/objctives/45544?app_key=<APP_KEY>&timestamp=<TIMESTAMP>&signature=<SIGNATURE>" \
-H "Accept: application/json"


Response:
{
    "id": 21344,
    "name": "My objective",
    "description": "",
    "created_at": "2021-01-28T18:28:23.492Z",
    "updated_at": "2021-01-29T09:21:33.533Z",
    "area_id": 2341123,
    "hoshin_id": 1234,
    "obj_pos": 1,
    "parent_id": null,
    "responsible_id": 34235345,
    "company_id": 2345234,
    "creator_id": 234234,
    "neglected": false,
    "blind": false,
    "deleted_at": null
})
  returns :objective, code: :ok
  def show
    hobo_show
  end
  
  def create
    obj = params["objective"]
    select_responsible(obj)
    hobo_create do
      redirect_to this.area.hoshin if valid? && !request.xhr?
    end
    log_event("Create objective", {objid: @this.id, name: @this.name})
  end
  
  api :POST, '/areas/:area_id/objectives', 'Create an objective for the given area'
  param_group :objective
  example %q(curl -X POST "https://www.hoshinplan.com/areas/124234/objectives?app_key=<APP_KEY>&timestamp=<TIMESTAMP>&signature=<SIGNATURE>" \
-H "Content-Type: application/json" \
-H "Accept: application/json" \
-d '{
  "name": "My new objective",
  "description": "This is my objective created through the API",
  "responsible_id": 213312
}')
  returns :objective, code: :created, desc: 'The newly created objective'
  def create_for_area
    hobo_create_for :area do
      respond_to do |format|
        format.html {
          redirect_to this.area.hoshin if valid? && !request.xhr?
        }
        format.json {
          render :json => self.this.to_json, :status => :created
        }
        format.xml {
          render :xml => self.this.to_xml, :status => :created
        }
      end
    end
    log_event("Create objective", {objid: @this.id, name: @this.name})
  end
  
  api :DELETE, '/objectives/:id', 'Delete an objective'
  returns nil, code: :no_content
  def destroy
    hobo_destroy do
      respond_to do |format|
        format.html {
          destroy_response
        }
        format.json {
          render nothing: true, status: :no_content
        }
        format.xml {
          render nothing: true, status: :no_content
        }
      end
    end
    log_event("Delete objective", {objid: @this.id, name: @this.name})
  end
  
  api :PUT, '/objectives/:id', 'Update an objective'
  param_group :objective
  formats ['json', 'xml']
  example %q(curl -X PUT "https://www.hoshinplan.com/objectives/32423?app_key=<APP_KEY>&timestamp=<TIMESTAMP>&signature=<SIGNATURE>" \
-H "Content-Type: application/json" \
-H "Accept: application/json" \
-d '{
  "description": "The new description"
}')
  returns :objective, code: :ok, desc: 'The updated objective'
  def update
    obj = params["objective"]
    select_responsible(obj)
    hobo_update do
      log_event("Update objective", {objid: @this.id, name: @this.name})
      respond_to do |format|
        format.html {
          redirect_to this.area.hoshin if valid? && !request.xhr?
        }
        format.json {
          render :json => self.this.to_json, :status => :ok
        }
        format.xml {
          render :xml => self.this.to_xml, :status => :ok
        }
      end
    end
  end
  
  def form
    if (params[:id]) 
      @this = find_instance
    else
      @this = Objective.new
      @this.company_id = params[:company_id]
      @this.hoshin_id = params[:hoshin_id]
      @this.area_id = params[:area_id]
    end
  end

end
