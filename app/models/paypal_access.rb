require 'paypal-sdk-rest'

class PaypalAccess
  
  def self.get_plans(status="ACTIVE")
     ret = PayPal::SDK::REST::Plan.all(status: status)
     Rails.logger.debug ret.inspect
     ret
  end
  
  def self.set_state(plan_id, state)
    plan = PayPal::SDK::REST::Plan.find(plan_id)
    resp = plan.update({op:'replace', path: "/", value:
              {
                  state: state
              }
           })
    if resp
      Rails.logger.info "Plan[#{plan.id}]"
    else
      raise IOError, plan.error.to_yaml
    end
  end
  
  def self.activate_plans
    ["P-9Y854540V66583901RLPMZQY","P-67J789623K7513512RK474DQ" ].each { |plan_id|
      set_state(plan_id, "ACTIVE")
    }
  end
  
  def self.create_plan(plan)
    plan = PayPal::SDK::REST::Plan.new({
          name: plan.name,
          description: plan.description,
          type: "INFINITE",
          payment_definitions: [
              {
                  name: "Standard Plan",
                  type: "REGULAR",
                  frequency_interval: plan.interval.to_s,
                  frequency: plan.frequency,
                  amount: {
                      currency: plan.amount_currency,
                      value: plan.amount_value.to_s
                  }
              }
          ],
          merchant_preferences: {
              "cancel_url": "https://#{Rails.application.routes.default_url_options[:host]}/payments/cancel",
              "return_url": "https://#{Rails.application.routes.default_url_options[:host]}/payments/correct",
              "max_fail_attempts": "3",
              "auto_bill_amount": "YES",
              "initial_fail_amount_action": "CANCEL"
          }
      })
      if plan.create
        Rails.logger.debug "Plan[#{plan.id}]"
        return plan
      else
        raise IOError, plan.error.to_yaml
      end
  end
  
  
  def self.create_agreement(plan)
    sd = (Time.now + 3.minutes).utc.iso8601
    agreement = PayPal::SDK::REST::Agreement.new({
          name: plan.name,
          description: plan.description,
          "start_date": sd,
          "plan": {
              "id": plan.id_paypal
          },
          "payer": {
              "payment_method": "paypal"
          }
    })
    if agreement.create
      Rails.logger.debug "Agreement[#{agreement.token}]"
      return agreement
    else
      raise IOError, agreement.error.to_yaml
    end
  end
  
  def self.execute_agreement(token)
    agreement = PayPal::SDK::REST::Agreement.new(token: token)
    if agreement.execute
      Rails.logger.debug "Agreement executed [#{agreement.token}]"
      return agreement
    else
      raise IOError, agreement.error.to_yaml
    end
  end
  
  def self.find_agreement(token)
    agreement = PayPal::SDK::REST::Agreement.find(token)
    if agreement
      Rails.logger.debug "Agreement found [#{agreement.token}]"
      return agreement
    else
      raise IOError, "Agreement with id #{token} not found"
    end
  end
  
  def self.sandbox?
    PayPal::SDK::Core::Config.config.mode == 'sandbox'
  end
  
end