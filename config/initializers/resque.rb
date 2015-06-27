require 'resque/status_server'

unless Rails.env.development?
  Resque::Server.use Rack::Auth::Basic do |user, password|
    user == 'login' && password == 'password'
  end
end