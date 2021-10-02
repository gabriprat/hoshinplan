class IndicatorsController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => :index

  auto_actions_for :objective, [:index, :new, :create]

  show_action :history

  web_method :form
  web_method :value_form
  web_method :delete_history
  web_method :data_update

  cache_sweeper :indicators_sweeper

  include FrontHelper


  include RestController


  def_param_group :indicator do
    param :name, String
    param :value, :decimal, 'The current value for this indicator'
    param :description, String
    param :ind_pos, :number, 'Used to sort the indicators in the hoshin view'
    param :frequency, %w[weekly monthly quarterly], 'The update frequency for this indicator'
    param :next_update, Date, 'The date of the next desired update'
    param :goal, :decimal, 'The value that would set this indicator to 100%'
    param :worst_value, :decimal, 'The value that would set this indicator to 0%'
    param :reminder, :boolean, 'Send email reminders to the owner when the next update date comes'
    param :show_on_parent, :boolean, 'Show this indicator in the parent Hoshin'
    param :show_on_charts, :boolean, 'Show this indicator in the Hoshin charts view'
    param :hoshin_id, :number, 'The id of the area this indicator belongs to', only_in: :response
    param :area_id, :number, 'The id of the area this indicator belongs to', only_in: :response
    param :company_id, :number, 'The id of the company this indicator belongs to', only_in: :response
    param :creator_id, :number, 'The id of the user that created this indicator', only_in: :response
    param :objective_id, :number, 'The id of the objective this indicator belongs to'
    param :responsible_id, :number, 'The id of the user that is responsible for this indicator'
    param :last_update, Date, 'The timestamp of the last time this indicator was updated', only_in: :response
    param :last_value, :decimal, 'The previous value for this indicator', only_in: :response
    param :created_at, Date, only_in: :response
    param :updated_at, Date, only_in: :response
    param :parent_objective_id, :number, 'The id of the parent objective of the objective this indicator belongs to', only_in: :response
    param :parent_area_id, :number, 'The id of the area of the parent objective of the objective this indicator belongs to', only_in: :response
    param :deleted_at, Date, 'The date when this indicator was deleted', only_in: :response
  end


  api :GET, '/indicators/:id', 'Get an indicator'
  example %q(curl "https://www.hoshinplan.com/indicators/45544?app_key=<APP_KEY>&timestamp=<TIMESTAMP>&signature=<SIGNATURE>" \
-H "Accept: application/json"


Response:
{
    "id": 45544,
    "name": "My indicator",
    "description": "This is my indicator created through the API",
    "value": "33.74",
    "frequency": "weekly",
    "next_update": "2021-08-08",
    "goal": "50.0",
    "created_at": "2021-07-08T18:20:01.530Z",
    "updated_at": "2021-07-30T11:19:33.893Z",
    "objective_id": 8786,
    "area_id": 4364,
    "ind_pos": 1,
    "last_update": "2021-08-01",
    "last_value": "39.6",
    "responsible_id": 252433,
    "company_id": 123420,
    "reminder": true,
    "worst_value": "30.0",
    "show_on_parent": false,
    "creator_id": 223553,
    "hoshin_id": 1235545,
    "show_on_charts": true,
    "parent_area_id": null,
    "parent_objective_id": null,
    "deleted_at": null
})
  returns :indicator, code: :ok
  def show
    hobo_show
  end

  def create
    delocalize_config = {last_update: :date, next_update: :date, value: :number, last_value: :number, goal: :number, worst_value: :number}
    obj = params["indicator"]
    obj.delocalize(delocalize_config)
    select_responsible(obj)
    hobo_create do
      redirect_to this.objective.area.hoshin if valid? && !request.xhr?
    end
    log_event("Create indicator", {objid: @this.id, name: @this.name})
  end

  api :POST, '/objectives/:objective_id/indicators', 'Create an indicator for the given objective'
  param_group :indicator, :as => :create
  formats ['json', 'xml']
  example %q(curl -X POST "https://www.hoshinplan.com/objectives/23423/indicators?app_key=<APP_KEY>&timestamp=<TIMESTAMP>&signature=<SIGNATURE>" \
-H "Content-Type: application/json" \
-H "Accept: application/json" \
-d '{
  "name": "My new indicator",
  "description": "This is my indicator created through the API",
  "responsible_id": 213312,
  "goal": "100",
  "worst_value": "0",
  "frequency": "weekly",
  "next_update": "2021-07-08T18:20:01.530Z"
}')
  returns :indicator, code: :created, desc: 'The newly created indicator'
  def create_for_objective
    hobo_create_for :objective do
      respond_to do |format|
        format.html {
          redirect_to this.objective.area.hoshin if valid? && !request.xhr?
        }
        format.json {
          render :json => self.this.to_json, :status => :created
        }
        format.xml {
          render :xml => self.this.to_xml, :status => :created
        }
      end
    end
    log_event("Create indicator", {objid: @this.id, name: @this.name})
  end

  api :DELETE, '/indicators/:id', 'Delete an indicator'
  example %q(curl -X DELETE "https://www.hoshinplan.com/indicators/45544?app_key=<APP_KEY>&timestamp=<TIMESTAMP>&signature=<SIGNATURE>" \
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
    log_event("Delete indicator", {objid: @this.id, name: @this.name})
  end

  api :PUT, '/indicators/:id', 'Update an indicator'
  param_group :indicator
  formats ['json', 'xml']
  example %q(curl -X PUT "https://www.hoshinplan.com/indicators/45544?app_key=<APP_KEY>&timestamp=<TIMESTAMP>&signature=<SIGNATURE>" \
-H "Content-Type: application/json" \
-H "Accept: application/json" \
-d '{
  "value": "50"
}')
  returns :indicator, code: :ok, desc: 'The updated indicator'
  def update
    delocalize_config = {last_update: :date, next_update: :date, value: :number, last_value: :number, goal: :number, worst_value: :number}
    old_value = nil
    obj = params[:indicator]
    obj.delocalize(delocalize_config)
    select_responsible(obj)
    if params[:indicator] && params[:indicator][:value]
      i = find_instance
      old_value = i.value
      i.value = params[:indicator][:value]
      i.value_will_change!
      if params[:indicator][:last_update]
        i.last_update = params[:indicator][:last_update]
        i.last_update_will_change!
      end
      #Empty change to keep the already changed attributes and the will_change! calls
      i.user_save(current_user)
      if request.xhr?
        update_response(nil, {})
      else
        respond_to do |format|
          format.json {render :json => find_instance.to_json}
          format.xml {render :xml => find_instance.to_xml}
          format.html {redirect_to this.objective.area.hoshin if valid? && !request.xhr?}
        end
      end
    else
      hobo_update do
        if request.xhr?
          hobo_ajax_response
        else
          respond_to do |format|
            format.json {render :json => find_instance.to_json}
            format.xml {render :xml => find_instance.to_xml}
            format.html {redirect_to this.objective.area.hoshin if valid? && !request.xhr?}
          end
        end
      end
  end

  log_event("Update indicator", {objid: @this.id, name: @this.name, value: @this.value, old_value: old_value.nil? ? @this.value : old_value})

end

def history
  @this = Indicator.find(params[:id])
  if request.xhr?
    hobo_ajax_response
  else
    respond_with(@this)
  end
end

def data_update
  @this = Indicator.find(params[:id])
  ihs = []
  last = {}
  JSON.parse(params[:json]).each_with_index {|h, idx|
    d = Date.strptime(h["day"], t('date.formats.default')) if h["day"].present?
    if (d)
      ih = @this.indicator_histories.find_or_initialize_by(day: d)
      ih.value = h["value"]; ih.goal = h["goal"]; ih.previous = h["previous"]; ih.comment = h["comment"]
      ih.company_id = Company.current_id
      ih.user_save(current_user)
      ihs.push(ih)
      if !h["value"].nil? && (last["last_update"].nil? || d > last["last_update"])
        last["last_update"] = d
        last["value"] = h["value"]
        last["goal"] = h["goal"]
      end
    end
  }
  @this.last_update = last["last_update"]
  @this.value = last["value"]
  @this.goal = last["goal"]
  @this.last_update_will_change!
  @this.next_update = @this.next_update_after(@this.last_update, @this.frequency)
  @this.indicator_histories = ihs
  @this.user_save(current_user)
  @this = Indicator.where(id: params[:id]).includes(:indicator_histories).first
  hobo_ajax_response
  log_event("Upload indicator values", {objid: @this.id, name: @this.name})
end

def delete_history
  @this = find_instance
  IndicatorHistory.delete_all(:indicator_id => @this.id)
  redirect_to @this, :action => :history
end

def form
  if (params[:id])
    @this = find_instance
  else
    @this = Indicator.new
    @this.company_id = params[:company_id]
    @this.hoshin_id = params[:hoshin_id]
    @this.objective_id = params[:objective_id]
    @this.area_id = params[:area_id]
  end
end

def value_form
  @this = find_instance
end

end
