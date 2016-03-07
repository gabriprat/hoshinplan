PayPal::SDK.load("config/paypal.yml", Rails.env)
PayPal::SDK.logger = Logger.new(STDOUT)
