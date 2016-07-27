class BillingDetailsController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => [:new, :index]

  auto_actions_for :company, [:new, :create]

  def new_for_company
    @billing_plan = BillingPlan.find(params[:plan])
    hobo_new_for :company
    log_event("Checkout", {plan_name: @billing_plan.name, plan_id: @billing_plan.id})
  end

  def create
    @billing_plan = BillingPlan.find(params[:plan_id])
    hobo_create
    log_event("Checkout", {plan_name: @billing_plan.name, plan_id: @billing_plan.id})
  end

  def edit
    @billing_plan = BillingPlan.find(params[:plan]) if params[:plan]
    hobo_show
    log_event("Checkout", {plan_name: @this.active_subscription._?.plan_name, plan_id: @this.active_subscription._?.billing_plan_id})
  end

  def create_for_company
    @this = BillingDetail.where(company_id: params[:company_id]).first
    subscription_params = params[:billing_detail][:active_subscription]
    params[:billing_detail].delete(:active_subscription)
    if params[:plan_id]
      @billing_plan = BillingPlan.find(params[:plan_id])
      subscription_params.merge!({
                                     plan_name:  @billing_plan.name,
                                     amount_value: @billing_plan.amount_value,
                                     monthly_value: @billing_plan.monthly_value,
                                     amount_currency: @billing_plan.amount_currency
                                 })
    end
    hobo_create_for :company do
      if valid?
        _update_subscription(subscription_params)
      end
    end
  end

  def update
    @this = find_instance
    subscription_params = params[:billing_detail][:active_subscription]
    params[:billing_detail].delete(:active_subscription)
    if params[:plan_id]
      @billing_plan = BillingPlan.find(params[:plan_id])
      subscription_params.merge!({
           plan_name:  @billing_plan.name,
           amount_value: @billing_plan.amount_value,
           monthly_value: @billing_plan.monthly_value,
           amount_currency: @billing_plan.amount_currency
      })
    end
    hobo_update do
      _update_subscription(subscription_params)
    end
  end

  def _update_subscription(subscription_params)
    if valid?
      self.this.save
      s = self.this.active_subscription
      old_remaining_amount = s.remaining_amount
      old_period = s.billing_period
      new_subscription = s.new_record?
      ActiveRecord::Base.transaction do
        begin
          update_stripe_billing_details
          self.this.active_subscription = subscription_params
          amount = charge(old_remaining_amount, old_period)
          s = self.this.active_subscription
          if (new_subscription)
            log_event("Create subscription", {users: s.users, period: s.billing_period, charged_amount: amount, total_amount: s.total_amount, plan_name: @billing_plan.name, plan_id: @billing_plan.id})
          else
            log_event("Update subscription", {users: s.users, period: s.billing_period, charged_amount: amount, total_amount: s.total_amount, plan_name: @billing_plan.name, plan_id: @billing_plan.id})
          end
          redirect_to this.company, action: :collaborators
        rescue Stripe::CardError => _
          flash.now[:error] = I18n.t('errors.invalid_credit_card')
          update_response(false)
          log_event("Payment error", {message: _.message})
          raise ActiveRecord::Rollback
        end
      end
    end
  end

  def update_stripe_billing_details
    if @this.stripe_client_id.nil?
      customer = Stripe::Customer.create(
          :description => current_user.name,
          :source => params[:stripeToken],
          :email => @this.contact_email
      )
      @this.stripe_client_id = customer.id
      @this.save
    else
      customer = Stripe::Customer.retrieve(@this.stripe_client_id)
    end
    if params[:number].present? && params[:expiry].present? && params[:name].present? && params[:cvc].present?
      exp_month,exp_year = params[:expiry].split("/").map {|v| v.strip}

      card = customer.sources.create({source: {
          object: 'card',
          exp_month: exp_month,
          exp_year: exp_year,
          number: params[:number].gsub(' ', ''),
          cvc: params[:cvc],
          name: params[:name],
          address_city: @this.city,
          address_country: @this.country,
          address_line1: @this.address_line_1,
          address_line2: @this.address_line_2,
          address_state: @this.state,
          address_zip: @this.zip
      }})
      @this.card_brand = card.brand
      @this.card_last4 = card.last4
      @this.card_exp_month = card.exp_month
      @this.card_exp_year = card.exp_year
      @this.card_stripe_token = card.id
      @this.save
    end
  end

  def charge(old_remaining_amount=0, old_period=nil)
    subscription = self.this.active_subscription
    subscription.billing_detail_id = self.this.id
    amount = subscription.charge(full_amount=false, old_remaining_amount)
    track_charge(amount)
    return amount
  end
end