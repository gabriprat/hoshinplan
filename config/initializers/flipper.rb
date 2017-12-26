require 'flipper/adapters/memory'
require 'flipper/adapters/redis_cache'
require 'flipper/middleware/setup_env'
require 'flipper/middleware/memoizer'

redis = Redis.new(url: ENV['REDIS_URL'])
memory_adapter = Flipper::Adapters::Memory.new
adapter = Flipper::Adapters::RedisCache.new(memory_adapter, redis, 4800)
flipper = Flipper.new(adapter)
Rails.application.config.middleware.use Flipper::Middleware::SetupEnv, flipper
Rails.application.config.middleware.use Flipper::Middleware::Memoizer

Flipper.register(:admins) do |actor|
  actor.respond_to?(:admin?) && actor.admin?
end

Flipper.register(:beta) do |actor|
  actor.respond_to?(:beta_access?) && actor.beta_access?
end

Flipper.register(:startup) do |actor|
  actor.respond_to?(:startup?) && actor.startup?
end

Flipper.register(:enterprise) do |actor|
  actor.respond_to?(:enterprise?) && actor.enterprise?
end


class IsAdministrator
  def self.matches?(request)
    request.session[:init] = true
    if request.session[:user]
      current_user = Hobo::Model.find_by_typed_id(request.session[:user])
    end
    current_user.present? && current_user.respond_to?(:administrator?) && current_user.administrator?
  end
end

