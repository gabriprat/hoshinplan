class GenericCommentsController < ApplicationController

  hobo_model_controller

  auto_actions :index, :new, :create

  def index
    fail unless params[:id].present? && params[:type].present?
    self.this = GenericComment.where(params[:type].singularize + '_id = ?', params[:id].to_i)
                    .order(created_at: :desc).paginate(:page => params[:page], :per_page => params[:per_page] || 15)
    @model = params[:type].singularize.capitalize.constantize
    @source = @model.with_deleted.find(params[:id].to_i.to_s)
    if @model == Hoshin || @model == Company
      @back = @source
    else
      @back = Hoshin.unscoped.find(@source.hoshin_id)
    end
    render :json => self.this.to_json
  end

  def create
    fail params.inspect
  end

end

class CompanyCommentsController < ApplicationController
  hobo_model_controller

  auto_actions_for :company, [:new, :create]
end


class HoshinCommentsController < ApplicationController
  hobo_model_controller

  auto_actions_for :hoshin, [:new, :create]
end


class GoalCommentsController < ApplicationController
  hobo_model_controller

  auto_actions_for :goal, [:new, :create]
end


class AreaCommentsController < ApplicationController
  hobo_model_controller

  auto_actions_for :area, [:new, :create]
end

class ObjectiveCommentsController < ApplicationController
  hobo_model_controller

  auto_actions_for :objective, [:new, :create]
end

class IndicatorCommentsController < ApplicationController
  hobo_model_controller

  auto_actions_for :indicator, [:new, :create]
end

class TaskCommentsController < ApplicationController
  hobo_model_controller

  auto_actions_for :task, [:new, :create]
end