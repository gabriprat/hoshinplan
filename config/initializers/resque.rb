require 'resque/server'
require 'resque/failure/newrelic'

unless Rails.env.development?
  Resque::Server.use Rack::Auth::Basic do |user, password|
    user == 'login' && password == 'password'
  end
end
Resque.logger = Rails.logger

Resque::Failure.backend = Resque::Failure::Newrelic

Resque::Plugins::Timeout.timeout = 300