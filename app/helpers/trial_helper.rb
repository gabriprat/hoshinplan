module TrialHelper
  def self.upgrade_button_visible?(company, controller)
    #fail (Company.current_company.subscriptions_count == 0).to_yaml + controller.controller_name.to_yaml + controller.action_name
    company &&
        !company.unlimited &&
        company.subscriptions_count == 0 &&
        controller.controller_name != 'billing_details' &&
        controller.action_name != 'upgrade'
  end

  def upgrade_button_visible?
    TrialHelper.upgrade_button_visible?(Company.current_company, controller)
  end
end