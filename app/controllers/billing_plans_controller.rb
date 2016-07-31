class BillingPlansController < ApplicationController
  
  hobo_model_controller
  
  auto_actions :index

  index_action :pricing
  
  def pricing
    @freq = params[:freq]
    @freq ||= :MONTH
    @this = BillingPlan.where(frequency: [:WEEK, @freq]).where.not(position: 1)
    hobo_index do
      render template: 'payments/pricing'
    end
  end
end