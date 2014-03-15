class IndicatorsController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => :index
  
  auto_actions_for :objective, [:index, :new, :create]
  
  show_action :history
  
  cache_sweeper :indicators_sweeper
  
  
  include RestController
  
  
  def update
    obj = params["indicator"]
    select_responsible(obj)
    hobo_update do
      redirect_to this.objective.area.hoshin if valid? && !request.xhr?
    end
  end
  
  def create
    obj = params["indicator"]
    select_responsible(obj)
    hobo_create
  end
  
  def update
    if params[:history_values]
      error = false
      begin
        options = {}
        if t('number.format.separator') == ','
          options[:col_sep] = ';'
        end
        CSV.parse( params[:history_values], options) do |row|
          d = Date.parse(row[0])
          v = row[1].delete(t('number.format.delimiter')).gsub(t('number.format.separator'),'.').to_f unless row[1].nil?
          g = row[2].delete(t('number.format.delimiter')).gsub(t('number.format.separator'),'.').to_f unless row[2].nil?
          ih = find_instance.indicator_histories.find_or_initialize_by_day(d)
          ih.value = v
          ih.goal = g
          ih.save!
        end
      redirect_to find_instance, {:action => :history}
      end
    else
      if params[:indicator] && params[:indicator][:value]
        i = find_instance
        i.value = params[:indicator][:value]
        i.value_will_change!
        hobo_update(i, :attributes => :value)
      else
        hobo_update
      end
      
    end
  end
  
  def history
      @this = Indicator.includes(:indicator_histories).find(params[:id])
      if request.xhr?
        hobo_ajax_response
      else
        respond_with(@this)
      end
  end
end
