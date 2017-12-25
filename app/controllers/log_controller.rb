class LogController < ApplicationController

  hobo_model_controller

  auto_actions :index
  
  def index
    fail unless params[:id].present? && params[:type].present?
    logs = params[:search] ? Hobo.find_by_search(params[:search], [Log])[Log.name] : Log
    self.this = logs.where(params[:type].singularize + '_id = ?',  params[:id].to_i)
      .order(created_at: :desc).paginate(:page => params[:page], :per_page => 15)
    @model = params[:type].singularize.capitalize.constantize
    @source = @model.with_deleted.find(params[:id].to_i.to_s)
    if @model == Hoshin || @model == Company
      @back = @source
    else
      @back = Hoshin.unscoped.find(@source.hoshin_id)
    end
    if request.xhr?
      hobo_ajax_response
    else
      hobo_index
    end
  end

end
