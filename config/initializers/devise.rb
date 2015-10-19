require 'omniauth-openid'
require 'openid/store/filesystem'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :open_id, :name => 'openid', :store => OpenID::Store::Filesystem.new('./tmp')
  provider :google_oauth2, ENV["GOOGLE_CLIENT"], ENV["GOOGLE_SECRET"],
           {
             :approval_prompt => "auto",
             :scope => "email profile"
             
           } 
end

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE if Rails.env.development? 

OmniAuth.config.on_failure do |env|
  fail env['omniauth.error'].to_yaml if Rails.env.development? 
  st = ""
  params = Rack::Utils.parse_query(env["ORIGINAL_FULLPATH"]) if env["ORIGINAL_FULLPATH"]
  error_reason_param = params["openid.error"] ? "&error_reason=" + params["openid.error"] : "" 
  message_key = env['omniauth.error.type']
  error_param = env['omniauth.error'] && env['omniauth.error'].respond_to?("error") ? "&error=" + env['omniauth.error'].error.to_s : ""
  error_param ||= env['omniauth.error'].to_s
  error_reason_param ||= env['omniauth.error'] && env['omniauth.error'].respond_to?("error_reason") ? "&error_reason=" + env['omniauth.error'].error_reason : ""
  origin_query_param = env['omniauth.origin'] ? "&origin=#{Rack::Utils.escape(env['omniauth.origin'])}" : ""
  strategy_name_query_param = env['omniauth.error.strategy'] ? "&strategy=#{env['omniauth.error.strategy'].name}" : ""
  new_path = "#{OmniAuth.config.path_prefix}/failure?message=#{message_key}#{origin_query_param}#{strategy_name_query_param}#{error_param}#{error_reason_param}"
  [302, {'Location' => new_path, 'Content-Type'=> 'text/html'}, []]
end

module OmniAuth
  module Strategies
    # OmniAuth strategy for connecting via OpenID. This allows for connection
    # to a wide variety of sites, some of which are listed [on the OpenID website](http://openid.net/get-an-openid/).
    class OpenID
      def dummy_app
              lambda{|env| [401, {"WWW-Authenticate" => Rack::OpenID.build_header(
                :identifier => identifier,
                :return_to => callback_url,
                :required => options.required,
                :optional => options.optional,
                :method => 'get'
              )}, []]}
      end
    end
  end
end