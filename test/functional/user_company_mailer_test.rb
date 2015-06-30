require 'test_helper'

class UserCompanyMailerTest < ActionController::TestCase
  
  test "invite" do
      user = users(:one)
      # Send the email, then test that it got queued
      email = UserCompanyMailer.welcome(user).deliver!
      assert_not ActionMailer::Base.deliveries.empty?
 
      # Test the body of the sent email contains what we expect it to
      assert_equal ['hello@hoshinplan.com'], email.from
      assert_equal [user.email_address], email.to      
  end
end
