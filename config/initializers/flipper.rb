require 'flipper/adapters/activerecord'

# config/application.rb
adapter = Flipper::Adapters::ActiveRecord.new
$flipper = Flipper.new(adapter)
Rails.application.config.middleware.use Flipper::Middleware::Memoizer, lambda { $flipper }

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


class CanAccessFlipperUI
  def self.matches?(request)
    request.session[:init] = true
    current_user = Hobo::Model.find_by_typed_id(request.session[:user])
    current_user.present? && current_user.respond_to?(:administrator?) && current_user.administrator?
  end
end

