Rails.application.config.middleware.use OmniAuth::Builder do
  OmniAuth::MultiProvider.register(
      self,
      provider_name: :saml,
      identity_provider_id_regex: /[\w\.-]+/,
      path_prefix: '/auth/saml',
      callback_suffix: 'callback',
      name_identifier_format: 'urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress',
      issuer: 'https://www.hoshinplan.com',
      allowed_clock_drift: 5.seconds
  ) do |identity_provider_id, rack_env|
    # Customize this code to return the appropriate SAML options for the given identity provider
    # See omniauth-saml for details on the supported options
    identity_provider = SamlProvider.find_by!(email_domain: identity_provider_id)
    identity_provider.options
  end
end

class SamlDynamicRouter
  def self.load
    Hoshinplan::Application.routes.draw do
      begin
        SamlProvider.all.each do |prov|
          Rails.logger.debug "Routing #{prov.email_domain}"
          get "/#{prov.email_domain}", :to => redirect('/auth/saml_' + prov.email_domain)
        end
      rescue ActiveRecord::StatementInvalid => e
      end
    end
  end

  def self.reload
    Hoshinplan::Application.routes_reloader.reload!
  end
end


class SamlOmniauthSetup
  # OmniAuth expects the class passed to setup to respond to the #call method.
  # env - Rack environment
  def self.call(env)
    new(env).setup
  end

  # Assign variables and create a request object for use later.
  # env - Rack environment
  def initialize(env)
    @env = env
    @request = ActionDispatch::Request.new(env)
  end

  def setup
    @env['omniauth.strategy'].options.merge!(custom_credentials)
  end

  def custom_credentials
    dom = @request.path.gsub(/.*\/saml_([^\/]+).*/, '\1')
    prov = SamlProvider.find_by!(email_domain: dom)
    prov.options
  end
end


OmniAuth::Strategies::SAML.class_eval do

  private

  def initialize_copy(orig)
    super
    @options = @options.deep_dup
  end
end


module OmniAuthSamlPatch
  def on_auth_path?
    super || on_other_phase_path?
  end

  def on_other_phase_path?
    current_path.start_with?('/auth/saml')
  end

  def other_phase
    setup_phase if on_other_phase_path?
    super
  end
end

OmniAuth::Strategies::SAML.prepend(OmniAuthSamlPatch)

module OmniAuth
  module MultiProvider
    module Underscore
      def initialize(*args)
        super(*args)
        @provider_instance_path_regex = /^#{@path_prefix}_(?<identity_provider_id>#{@identity_provider_id_regex})/
        @request_path_regex = /#{@provider_instance_path_regex}\/?$/
        @callback_path_regex = /#{@provider_instance_path_regex}\/#{@callback_suffix}\/?$/
        @callback_path_regex = /#{@provider_instance_path_regex}\/#{@callback_suffix}\/?$/
      end

      private

      def add_path_options(strategy, identity_provider_id)
        strategy.options.merge!(
            request_path: "#{path_prefix}_#{identity_provider_id}",
            callback_path: "#{path_prefix}_#{identity_provider_id}/#{callback_suffix}"
        )
      end
    end
  end
end

OmniAuth::MultiProvider::Handler.prepend(OmniAuth::MultiProvider::Underscore)