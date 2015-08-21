class BillingPlansController < ApplicationController
  
  hobo_model_controller
  
  auto_actions :index
  
  def index
    @freq = params[:freq]
    @preq ||= :MONTH
    @this = BillingPlan.where(frequency: [:WEEK, @freq]) 
    hobo_index
  end
end