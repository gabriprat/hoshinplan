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
  
  def create
    obj = params["indicator"]
    select_responsible(obj)
    hobo_create do
      redirect_to this.objective.area.hoshin if valid? && !request.xhr?
    end
    log_event("Create indicator", {objid: @this.id, name: @this.name})
  end
  
  def create_for_objective
    hobo_create_for :objective do
      redirect_to this.objective.area.hoshin if valid? && !request.xhr?
    end
    log_event("Create indicator", {objid: @this.id, name: @this.name})
  end
  
  def destroy
    hobo_destroy
    log_event("Delete indicator", {objid: @this.id, name: @this.name})
  end
  
  def update
    
      old_value = nil
      obj = params[:indicator]
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
        response_block {redirect_to this.objective.area.hoshin if valid? && !request.xhr?} ||  update_response(nil, {})
      else
        hobo_update do
          redirect_to this.objective.area.hoshin if valid? && !request.xhr?
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
    if request.xhr?
      last = {}
      JSON.parse(params[:json]).each_with_index { |h,idx| 
        d = Date.strptime(h["day"], t('date.formats.default'))
        if (d)
          ih = @this.indicator_histories.find_or_initialize_by(day: d)
          ih.value = h["value"]; ih.goal = h["goal"]; ih.previous = h["previous"]
          ih.save!
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
      @this.save!
      @this = Indicator.where(id: params[:id]).includes(:indicator_histories).first
      hobo_ajax_response
    else
      respond_with(@this)
    end
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
      @this.objective_id = params[:objective_id]
      @this.area_id = params[:area_id]
    end
  end
  
  def value_form
      @this = find_instance
  end
end
