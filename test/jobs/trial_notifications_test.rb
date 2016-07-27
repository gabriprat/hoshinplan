require 'test_helper'

class TrialNotificationsTest < ActiveSupport::TestCase

  test "Execute subscription billing job" do
    Jobs::TrialNotifications.perform("hour" => Time.now.hour)
  end
end
