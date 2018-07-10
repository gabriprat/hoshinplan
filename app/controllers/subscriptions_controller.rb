class SubscriptionsController < ApplicationController

  hobo_model_controller

  auto_actions :new, :destroy
  
  auto_actions_for :user, [:index]
  
  protect_from_forgery :except => [:paypal_ipn] #Otherwise the request from PayPal wouldn't make it to the controller
  
  def cancel
    fail "Token not found" unless params[:token]
    subscription = SubscriptionPaypal.find_by_token(params[:token])
    subscription.status = "Pending"
    subscription.save!
  end
  
  def correct
    fail "Token not found" unless params[:token]
    subscription = SubscriptionPaypal.find_by_token(params[:token])
    agreement = PaypalAccess.execute_agreement(params[:token])
    agreement = PaypalAccess.find_agreement(agreement.id)
    subscription.id_paypal = agreement.id
    subscription.status = agreement.state
    subscription.save!
    SubscriptionPaypal.where(status: 'Active', company: subscription.company).where.not(id_paypal: subscription.id_paypal).each { |subscription_to_cancel|
      agreement_to_cancel = PaypalAccess.find_agreement(subscription_to_cancel.id_paypal)
      resp = agreement_to_cancel.cancel(note: "Canceling old subscription as you are buying a new one for the same company")
      if resp
        subscription_to_cancel.status = 'Canceled'
        subscription_to_cancel.save!
      else
        track_exception "Failed canceling subscription with id=#{subscription.id_paypal}"
      end
    }
    flash[:notice] = t "payments.correct.heading"
    if session[:payment_return_to]
      redirect_to session[:payment_return_to]
      session[:payment_return_to] = nil
    else
      redirect_to :back
    end
  end
  
  def pricing
  end
  
  def index_for_user
    company_ids =  User.find(params[:user_id]).all_companies.map {|c| c.id }
    finder = Subscription.includes(:billing_plan, :company, :invoices).where(company_id: company_ids, status: 'Active').references(:billing_plan, :company)
    search = params[:search].strip.upcase if params[:search]
    unless search.blank?
      finder = finder.where("upper(companies.name) LIKE ? OR subscriptions.id_paypal LIKE ? OR upper(billing_plans.name) LIKE ?", "%#{search}%","%#{search}%","%#{search}%")
    end
    sort = parse_sort_param("company" => "companies.name", "id_paypal" => "subscriptions.s.id_paypal", "billing_plan.name" => "billing_plans.name")
    if sort
      finder = finder.order(sort)
    end
    hobo_index_for :user, finder.paginate(:page => params[:page], :per_page => 30)
  end
  
  def create
    fail "Missing company" if params[:company].blank?
    plan = BillingPlan.where(id_paypal: params[:product]).first
    agreement = PaypalAccess.create_agreement(plan)
    agreement.links.each {|link|
      if link.rel == 'approval_url'
        subscription =SubscriptionPaypal.new
        subscription.token = agreement.token
        subscription.status = "Pending"
        #subscription.billing_plan = plan
        subscription.sandbox = PaypalAccess.sandbox?
        subscription.amount_value = plan.amount_value
        subscription.amount_currency = plan.amount_currency
        subscription.company_id = params[:company]
        subscription.user = current_user
        subscription.save!
        log_event("Paypal redirection", {product: plan.name})
        redirect_to link.href
        return
      end
    }
    fail "Redirection link not found" + agreement.to_yaml
  end
  
  # This is the callback from stripe
  def stripe_subscription_checkout
    plan_id = params[:plan]
    plan = Stripe::Plan.retrieve(plan_id)
    
    if current_user.stripe_id.present?
      customer = Stripe::Customer.retrieve(current_user.stripe_id)
    else
      customer = Stripe::Customer.create(
            :description => current_user.name,
            :source => params[:stripeToken],
            :email => current_user.email_address
          )
      current_user.stripe_id = customer.id
      current_user.save!
    end
    
    stripe_subscription = customer.subscriptions.create(:plan => plan.id)

    plan = BillingPlan.where(stripe_id: params[:plan]).first
    
    subscription = SubscriptionStripe.new
    subscription.token = stripe_subscription.id
    subscription.status = stripe_subscription.status.capitalize
    #subscription.billing_plan = plan
    subscription.sandbox = !stripe_subscription.plan.livemode
    subscription.amount_value = plan.amount_value
    subscription.amount_currency = plan.amount_currency
    subscription.company_id = params[:company]
    subscription.user = current_user
    subscription.save!
    Rails.logger.debug stripe_subscription.to_yaml
    
    flash[:notice] = t "payments.correct.heading"
    if session[:payment_return_to]
      redirect_to session[:payment_return_to]
      session[:payment_return_to] = nil
    else
      redirect_to :back
    end
    log_event "Create subscription", {objid: subscription.id, company_id: subscription.company_id, name: plan.name, amount: plan.amount_value, frequency: plan.frequency, currency: plan.amount_currency}
  end
end


class SubscriptionPaypalsController < ApplicationController

  hobo_model_controller

  auto_actions :new, :destroy
  
  def destroy
    @this = find_instance
    @this.cancel
    log_event "Cancel subscription", {objid: @this.id, company_id: @this.company_id, name: @this.billing_plan._?.name, amount: @this.amount_value, frequency: @this.billing_plan._?.frequency, currency: @this.amount_currency}
    if request.xhr?
      hobo_ajax_response
    else
      redirect_to :back
    end
  end
  
end

class SubscriptionStripesController < ApplicationController
  
  hobo_model_controller

  auto_actions :new, :destroy
  
  def destroy
    @this = find_instance
    @this.cancel
    log_event "Cancel subscription", {objid: @this.id, company_id: @this.company_id, name: @this.plan_name, users: @this.users, amount: @this.total_amount, frequency: @this.billing_period, currency: @this.amount_currency}
    if request.xhr?
      hobo_ajax_response
    else
      redirect_to :back
    end
  end

end


