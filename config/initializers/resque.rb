require 'resque/server'

unless Rails.env.development?
  Resque::Server.use Rack::Auth::Basic do |user, password|
    user == 'login' && password == 'password'
  end
end
Resque.logger = Logger.new 'log/resque.log'
Resque.logger.level = Logger::DEBUG