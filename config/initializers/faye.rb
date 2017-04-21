require File.expand_path('../../csrf_protection.rb', __FILE__)
require File.expand_path('../../../lib/faye/authentication.rb', __FILE__)
require File.expand_path('../../../lib/faye/authentication/server_extension.rb', __FILE__)
Rails.application.configure do
  config.middleware.delete Rack::Lock
  config.middleware.use FayeRails::Middleware, mount: '/ws', :timeout => 25, server: 'passenger', engine: {type: Faye::Redis, uri: ENV["REDIS_URL"]} do
    map '/comment/**' => FayeCommentController
    map default: :block
  end
end

