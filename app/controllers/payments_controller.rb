class PaymentsController < ApplicationController

  hobo_model_controller

  auto_actions :new, :destroy
  
  auto_actions_for :user, [:index]
  
  protect_from_forgery :except => [:paypal_ipn] #Otherwise the request from PayPal wouldn't make it to the controller
  
  def cancel
    fail "Token not found" unless params[:token]
    payment = Payment.find_by_token(params[:token])
    payment.status = "Pending"
    payment.save!
  end
  
  def destroy
    @this = find_instance
    if (@this.id_paypal)
      agreement = PaypalAccess.find_agreement(@this.id_paypal)
      agreement.cancel(note: "Canceled through Hoshinplan.com by " + current_user.email_address)
    end
    @this.status = 'Canceled'
    @this.save!
    if request.xhr?
      hobo_ajax_response
    else
      redirect_to :back
    end
  end
  
  def correct
    fail "Token not found" unless params[:token]
    payment = Payment.find_by_token(params[:token])
    agreement = PaypalAccess.execute_agreement(params[:token])
    agreement = PaypalAccess.find_agreement(agreement.id)
    payment.id_paypal = agreement.id
    payment.status = agreement.state
    payment.save!
    Payment.where(status: 'Active', company: payment.company).where.not(id_paypal: payment.id_paypal).each { |payment_to_cancel|
      agreement_to_cancel = PaypalAccess.find_agreement(payment_to_cancel.id_paypal)
      resp = agreement_to_cancel.cancel(note: "Canceling old subscription as you are buying a new one for the same company")
      if resp
        payment_to_cancel.status = 'Canceled'
        payment_to_cancel.save!
      else
        track_exception "Failed canceling payment with id=#{payment.id_paypal}"
      end
    }
    flash[:notice] = t "payments.correct.heading"
    if session[:payment_return_to]
      redirect_to session[:payment_return_to]
      session[:payment_return_to] = nil
    else
      redirect_to "/"
    end
  end
  
  def pricing
  end
  
  def index_for_user
    finder = Payment.includes(:billing_plan, :company).where(user_id: params[:user_id], status: 'Active').references(:billing_plan, :company)
    search = params[:search].strip.upcase if params[:search]
    unless search.blank?
      finder = finder.where("upper(companies.name) LIKE ? OR payments.id_paypal LIKE ? OR upper(billing_plans.name) LIKE ?", "%#{search}%","%#{search}%","%#{search}%")
    end
    sort = parse_sort_param("company" => "companies.name", "id_paypal" => "payments.id_paypal", "billing_plan.name" => "billing_plans.name")
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
        payment = Payment.new
        payment.token = agreement.token
        payment.status = "Pending"
        payment.billing_plan = plan
        payment.sandbox = PaypalAccess.sandbox?
        payment.amount_value = plan.amount_value
        payment.amount_currency = plan.amount_currency
        payment.company_id = params[:company]
        payment.user = current_user
        payment.save!
        log_event("Paypal redirection", {product: plan.name})
        redirect_to link.href
        return
      end
    }
    fail "Redirection link not found" + agreement.to_yaml
  end
end
