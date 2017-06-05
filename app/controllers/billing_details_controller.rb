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
    create_for_company
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
    if @this.company.payment_error && params[:billing_detail] && params[:billing_detail][:card_stripe_token]
      @this.company.payment_error = nil
      @this.company.save!(validate: false)
    end
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
      if subscription_params
        _update_subscription(subscription_params, params[:r]._?.gsub(/[^0-9A-Za-z_\/-]/,''))
      else
        redirect_to params[:page_path] if valid?
      end
    end
  end

  def _update_subscription(subscription_params, redirect_uri=nil)
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
          self.this.active_subscription.save! # using save! to raise validation errors
          amount = charge(old_remaining_amount, old_period)
          if amount > 0 && self.this.company.payment_error
            self.this.company.payment_error = nil
            self.this.company.save!(validate: false)
          end
          s = self.this.active_subscription
          if (new_subscription)
            log_event("Create subscription", {users: s.users, period: s.billing_period, charged_amount: amount, total_amount: s.total_amount, plan_name: @billing_plan.name, plan_id: @billing_plan.id})
          else
            log_event("Update subscription", {users: s.users, period: s.billing_period, charged_amount: amount, total_amount: s.total_amount, plan_name: s.plan_name, plan_id: s.billing_plan_id})
          end
          if redirect_uri.present?
            redirect_to redirect_uri
          else
            redirect_to this.company, action: :collaborators
          end
        rescue Stripe::CardError => _
          flash.now[:error] = I18n.t('errors.invalid_credit_card')
          update_response(false)
          log_event("Payment error", {message: _.message})
          raise ActiveRecord::Rollback
        rescue ActiveRecord::RecordInvalid => _
          flash.now[:error] = I18n.t('errors.invalid_subscription')
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
          :source => @this.card_stripe_token,
          :email => @this.contact_email
      )
    else
      customer = Stripe::Customer.retrieve(@this.stripe_client_id)
      if params[:billing_detail]._?[:card_stripe_token].present?
        customer.source = params[:billing_detail][:card_stripe_token]
        customer.save
      end
    end
    @this.stripe_client_id = customer.id
    @this.card_brand = customer.sources.data[0].brand
    @this.card_last4 = customer.sources.data[0].last4
    @this.card_exp_month = customer.sources.data[0].exp_month
    @this.card_exp_year = customer.sources.data[0].exp_year
    @this.card_stripe_token = customer.sources.data[0].id
    @this.save
  end

  def charge(old_remaining_amount=0, old_period=nil)
    subscription = self.this.active_subscription
    subscription.billing_detail_id = self.this.id
    amount = subscription.charge(full_amount=false, old_remaining_amount, request._?.remote_ip)
    return amount
  end
end