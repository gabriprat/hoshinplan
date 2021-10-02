class GoalsController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => :index
  
  auto_actions_for :hoshin, [:new, :create]
  web_method :form
  
  
  cache_sweeper :goals_sweeper

  include RestController

  def_param_group :goal do
    param :id, :number, only_in: :response
    param :name, String, action_aware: true, required: true
    param :created_at, Date, only_in: :response
    param :updated_at, Date, only_in: :response
    param :hoshin_id, :number, 'The id of the area this goal belongs to', only_in: :response
    param :company_id, :number, 'The id of the company this objective belongs to', only_in: :response
    param :position, :number, 'Used to sort the goals in the hoshin view'
  end

  api :GET, '/goals/:id', 'Get a long term goal'
  example %q(curl "https://www.hoshinplan.com/goals/45544?app_key=<APP_KEY>&timestamp=<TIMESTAMP>&signature=<SIGNATURE>" \
-H "Accept: application/json"


Response:
{
    "id": 21344,
    "name": "My goal",
    "created_at": "2021-01-28T18:28:23.492Z",
    "updated_at": "2021-01-29T09:21:33.533Z",
    "hoshin_id": 1234,
    "position": 1,
    "company_id": 2345234,
    "creator_id": 234234,
    "deleted_at": null
})
  returns :goal, code: :ok
  def show
    hobo_show
  end
  
  def create
    hobo_create do
      redirect_to this.hoshin if valid? && !request.xhr?
    end
  end

  api :PUT, '/goals/:id', 'Update a long term goal'
  param_group :goal
  formats ['json', 'xml']
  example %q(curl -X PUT "https://www.hoshinplan.com/goals/45544?app_key=<APP_KEY>&timestamp=<TIMESTAMP>&signature=<SIGNATURE>" \
-H "Content-Type: application/json" \
-H "Accept: application/json" \
-d '{
  "name": "This is the new name"
}')
  returns :goal, code: :ok, desc: 'The updated long term goal'
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

  api :POST, '/hoshins/:hoshin_id/goals', 'Create a long term goal for the given hoshin'
  param_group :goal, :as => :create
  formats ['json', 'xml']
  example %q(curl -X POST "https://www.hoshinplan.com/hoshins/12312/goals?app_key=<APP_KEY>&timestamp=<TIMESTAMP>&signature=<SIGNATURE>" \
-H "Content-Type: application/json" \
-H "Accept: application/json" \
-d '{
  "name": "My new goal"
}')
  returns :goal, code: :created, desc: 'The newly created goal'
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
  end

  api :DELETE, '/goals/:id', 'Delete a long term goal'
  example %q(curl -X DELETE "https://www.hoshinplan.com/goals/45544?app_key=<APP_KEY>&timestamp=<TIMESTAMP>&signature=<SIGNATURE>" \
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
    log_event("Delete goal", {objid: @this.id, name: @this.name})
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
