class BillingDetailsController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => [:new, :index]

  auto_actions_for :company, [:new, :create]

  def new_for_company
    @billing_plan = BillingPlan.find(params[:plan])
    hobo_new_for :company
  end

  def create
    @billing_plan = BillingPlan.find(params[:plan_id])
    hobo_create
  end

  def create_for_company
    ActiveRecord::Base.transaction do
      @this = BillingDetail.where(company_id: params[:company_id]).first
      @billing_plan = BillingPlan.find(params[:plan_id])
      params[:billing_detail][:active_subscription].merge!({
                                                               plan_name:  @billing_plan.name,
                                                               amount_value: @billing_plan.amount_value,
                                                               monthly_value: @billing_plan.monthly_value,
                                                               amount_currency: @billing_plan.amount_currency
                                                           })
      hobo_create_for :company do
        if valid?
          update_stripe_billing_details
          begin
            update_stripe_billing_details
            charge
            redirect_to this.company, action: :collaborators
          rescue Stripe::CardError => _
            flash[:error] = I18n.t('errors.invalid_credit_card')
            update_response(false)
            raise ActiveRecord::Rollback
          end
        end
      end
    end
  end

  def edit
    @billing_plan = BillingPlan.find(params[:plan]) if params[:plan]
    hobo_show
  end


  def update
    ActiveRecord::Base.transaction do
      if params[:plan_id]
        @billing_plan = BillingPlan.find(params[:plan_id])
        params[:billing_detail][:active_subscription].merge!({
                                                                 plan_name:  @billing_plan.name,
                                                                 amount_value: @billing_plan.amount_value,
                                                                 monthly_value: @billing_plan.monthly_value,
                                                                 amount_currency: @billing_plan.amount_currency
                                                             })
      end
      self.this = find_instance
      old_remaining_amount = self.this.active_subscription.remaining_amount
      hobo_update do

        if valid?
          begin
            update_stripe_billing_details
            charge(old_remaining_amount)
            redirect_to this.company, action: :collaborators
          rescue Stripe::CardError => _
            flash[:error] = I18n.t('errors.invalid_credit_card')
            update_response(false)
            raise ActiveRecord::Rollback
          end
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

  def charge(old_remaining_amount=0)

    subscription = self.this.active_subscription
    credit = self.this.company.credit || 0;
    pay_now = subscription.remaining_amount - old_remaining_amount - credit;
    pay_now = pay_now * (1.0 + self.this.tax_tpc.to_f/100.0)
    if pay_now > 0
      order = Stripe::Charge.create(
          amount: (pay_now * 100).to_i,
          currency: self.this.active_subscription.amount_currency,
          customer: self.this.stripe_client_id,
          description: self.this.active_subscription.plan_name + " plan #{@this.active_subscription.billing_period} (#{ @this.active_subscription.users} users)"
      )
      self.this.company.credit = 0
      self.this.company.save
    else
      self.this.company.credit = -pay_now
      self.this.company.save
    end
    return nil
  end
end