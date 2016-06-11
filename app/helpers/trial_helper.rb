module TrialHelper
  def upgrade_button_visible?
    #fail (Company.current_company.subscriptions_count == 0).to_yaml + controller.controller_name.to_yaml + controller.action_name
    Company.current_company &&
        !Company.current_company.unlimited &&
        Company.current_company.subscriptions_count == 0 &&
        controller.controller_name != 'billing_details' &&
        controller.action_name != 'upgrade'
  end
end