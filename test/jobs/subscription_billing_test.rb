require 'test_helper'

class SubscriptionBillingTest < ActiveSupport::TestCase

  test "Execute subscription billing job" do
    Jobs::SubscriptionBilling.perform("hour" => Time.now.hour)
  end
end
