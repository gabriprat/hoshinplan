class Admin::BillingPlansController < Admin::AdminSiteController
  
  hobo_model_controller
  
  auto_actions :all
  web_method :update_from_paypal
  web_method :sync_paypal
  index_action :from_paypal
  
  def from_paypal
    @status = params[:status]
    @status ||= "ACTIVE"
    @this = PaypalAccess.get_plans(@status).plans
    render "index"
  end
  
  def update_from_paypal
    fail "Status required" unless params[:status] 
    PaypalAccess.set_state(params[:id], params[:status])
    redirect_to :back
  end
  
  def update
    @this = find_instance
    if @this.status_paypal != params[:billing_plan][:status_paypal] 
      PaypalAccess.set_state(@this.id_paypal, params[:billing_plan][:status_paypal])
    end
    hobo_update redirect: :index
  end
  
  def update_paypal
    @this = find_instance
    fail "Status required" unless params[:billing_plan][:status_paypal] 
    PaypalAccess.set_state(@this.id_paypal, params[:billing_plan][:status_paypal])
    hobo_update
  end
  
  def sync_paypal
    @this = find_instance
    plan = nil
    ["CREATED", "ACTIVE", "INACTIVE"]. each { |status|
      break unless plan.nil?
      PaypalAccess.get_plans(status).plans.each { |p|
        if (p.name == @this.name)
          plan = p
          @this.id_paypal = plan.id
          @this.status_paypal = plan.state
          break
        end
      }
    }
    if (plan.nil?)
      plan = PaypalAccess.create_plan(@this)
    end
    @this.id_paypal = plan.id
    @this.status_paypal = plan.state
    @this.save!
    redirect_to @this
  end
  
end