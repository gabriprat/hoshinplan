class AreasController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => [:new, :index]
  
  auto_actions_for :hoshin, [:new, :create]
  
  show_action :charts
  web_method :form
  
  
  include RestController
  
  cache_sweeper :areas_sweeper
  
  def_param_group :area do
    param :id, :number, only_in: :response
    param :name, String
    param :description, String
    param :created_at, Date, only_in: :response
    param :updated_at, Date, only_in: :response
    param :hoshin_id, :number, 'The id of the area this area belongs to', only_in: :response
    param :company_id, :number, 'The id of the company this area belongs to', only_in: :response
    param :position, :number, 'Used to sort the areas in the hoshin view'
    param :creator_id, :number, 'The id of the user that created this area', only_in: :response
    param :color, String, 'The color of the postits for this area in the kanban view'
  end
  
  def create
    hobo_create do
      redirect_to this.hoshin if valid? && !request.xhr?
    end
    log_event("Create area", {objid: @this.id, name: @this.name})
  end
  
  api :POST, '/hoshins/:hoshin_id/areas', 'Create an area for the given Hoshin'
  param_group :area
  example %q(curl -X POST "https://www.hoshinplan.com/hoshins/12423/areas?app_key=<APP_KEY>&timestamp=<TIMESTAMP>&signature=<SIGNATURE>" \
-H "Content-Type: application/json" \
-H "Accept: application/json" \
-d '{
  "name": "My new area",
  "description": "This is my area created through the API",
  "color": "#DAF3F8"
}')
  returns :area, code: :created, desc: 'The newly created area'
  def create_for_hoshin
    hobo_create_for :hoshin do
      respond_to do |format|
        format.html {
          redirect_to this.hoshin if valid? && !request.xhr?
        }
        format.json {
          render :json => self.this.to_json, :status => :created
        }
        format.xml {
          render :xml => self.this.to_xml, :status => :created
        }
      end
    end
    log_event("Create area", {objid: @this.id, name: @this.name})
  end
  
  api :PUT, '/areas/:id', 'Edit an area'
  param_group :area
  formats ['json', 'xml']
  example %q(curl -X PUT "https://www.hoshinplan.com/areas/32423?app_key=<APP_KEY>&timestamp=<TIMESTAMP>&signature=<SIGNATURE>" \
-H "Content-Type: application/json" \
-H "Accept: application/json" \
-d '{
  "description": "The new description"
}')
  returns :area, code: :ok, desc: 'The updated area'
  def update
    hobo_update do
      respond_to do |format|
        format.html {
          redirect_to this.hoshin if valid? && !request.xhr?
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
  
  api :DELETE, '/areas/:id', 'Delete an area'
  example %q(curl -X DELETE "https://www.hoshinplan.com/areas/45544?app_key=<APP_KEY>&timestamp=<TIMESTAMP>&signature=<SIGNATURE>" \
-H "Accept: application/json")
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
    log_event("Delete area", {objid: @this.id, name: @this.name})
  end
  
  api :GET, '/areas/:id', 'Get an area'
  example %q(curl "https://www.hoshinplan.com/areas/31234?app_key=<APP_KEY>&timestamp=<TIMESTAMP>&signature=<SIGNATURE>" \
-H "Content-Type: application/json" \
-H "Accept: application/json"


Response:
{
    "id": 31234,
    "name": "My area",
    "description": "",
    "created_at": "2021-01-28T18:28:23.492Z",
    "updated_at": "2021-01-29T09:21:33.533Z",
    "hoshin_id": 1234,
    "position": 1,
    "company_id": 2345234,
    "color": "#DAF3F8",
    "deleted_at": null
})
  returns :area, code: :ok
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
