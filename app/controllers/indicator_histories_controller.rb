class IndicatorHistoriesController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => :index
  
  cache_sweeper :indicator_histories_sweeper
  
  include RestController
  
  def destroy
    self.this = model.user_find(current_user, 657)
    hobo_destroy do
      redirect_to :back if valid? && !request.xhr?
    end
  end

end
