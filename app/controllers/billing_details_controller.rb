class BillingDetailsController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => [:new, :index]

  auto_actions_for :company, [:new, :create]

  def new_for_company
    @secret = Stripe::SetupIntent.create.client_secret
    @billing_plan = BillingPlan.find(params[:plan])
    hobo_new_for :company
    log_event("Checkout", {plan_name: @billing_plan.name, plan_id: @billing_plan.id})
  end

  def create
    create_for_company
  end

  def edit
    @secret = Stripe::SetupIntent.create.client_secret
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
                                     plan_name: @billing_plan.name,
                                     amount_value: @billing_plan.amount_value,
                                     monthly_value: @billing_plan.monthly_value,
                                     amount_currency: @billing_plan.amount_currency,
                                     billing_plan_id: @billing_plan.id
                                 })
    end
    hobo_create_for :company do
      if valid?
        _update_subscription(@this, subscription_params)
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
                                     plan_name: @billing_plan.name,
                                     amount_value: @billing_plan.amount_value,
                                     monthly_value: @billing_plan.monthly_value,
                                     amount_currency: @billing_plan.amount_currency
                                 })
    end
    hobo_update do
      if subscription_params
        _update_subscription(@this, subscription_params, params[:r]._?.gsub(/[^0-9A-Za-z_\/-]/, ''))
      else
        if params[:billing_detail][:stripe_payment_method]
          update_stripe_billing_details
        end
        redirect_to params[:page_path] if valid?
      end
    end
  end

  def _update_subscription(billing_detail, subscription_params, redirect_uri=nil)
    if valid?
      ActiveRecord::Base.transaction do
        begin
          self.this.save
          s = self.this.active_subscription
          old_remaining_amount = s.remaining_amount
          old_period = s.billing_period
          new_subscription = s.new_record?
          update_stripe_billing_details
          s.assign_attributes subscription_params
          s.billing_detail_id = billing_detail.id
          s.user_id = User.current_id
          s.save! # using save! to raise validation errors
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
          @secret = Stripe::SetupIntent.create.client_secret
          flash.now[:error] = I18n.t('errors.invalid_credit_card')
          update_response(false)
          log_event("Payment error", {message: _.message})
          raise ActiveRecord::Rollback
        rescue Stripe::InvalidRequestError => _
          @secret = Stripe::SetupIntent.create.client_secret
          flash.now[:error] = I18n.t('errors.invalid_credit_card')
          update_response(false)
          log_event("Payment error", {message: _.message})
          raise ActiveRecord::Rollback
        rescue ActiveRecord::RecordInvalid => _
          @secret = Stripe::SetupIntent.create.client_secret
          flash.now[:error] = I18n.t('errors.invalid_subscription')
          update_response(false)
          log_event("Payment error", {message: _.message})
          raise ActiveRecord::Rollback
        end
      end
    end
  end

  def update_stripe_billing_details
    if params[:billing_detail]._?[:stripe_payment_method].blank?
      return
    end
    if @this.stripe_client_id.nil?
      customer = Stripe::Customer.create(
          :description => current_user.name,
          :email => @this.contact_email
      )
      payment_method = Stripe::PaymentMethod.attach(
          @this.stripe_payment_method,
          {
              customer: customer.id,
          }
      )
    else
      payment_method = Stripe::PaymentMethod.attach(
          @this.stripe_payment_method,
          {
              customer:  @this.stripe_client_id,
          }
      )
    end
    card = payment_method.card
    @this.stripe_client_id = payment_method.customer
    @this.card_brand = card.brand
    @this.card_last4 = card.last4
    @this.card_exp_month = card.exp_month
    @this.card_exp_year = card.exp_year
    @this.card_stripe_token = '-'
    @this.save
  end

  def charge(old_remaining_amount=0, old_period=nil)
    subscription = self.this.active_subscription
    subscription.billing_detail_id = self.this.id
    amount = subscription.charge(full_amount=false, old_remaining_amount, request._?.remote_ip, false)
    return amount
  end
end