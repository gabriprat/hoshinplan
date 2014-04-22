require 'omniauth-openid'
require 'openid/store/filesystem'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :open_id, :name => 'openid'
  provider :google_oauth2, ENV["GOOGLE_CLIENT"], ENV["GOOGLE_SECRET"],
           {
             :approval_prompt => "auto",
             :scope => "email profile"
             
           }         
end

OmniAuth.config.on_failure do |env|
  st = ""
  params = Rack::Utils.parse_query(env["ORIGINAL_FULLPATH"]) if env["ORIGINAL_FULLPATH"]
  error_reason_param = params["openid.error"] ? "&error_reason=" + params["openid.error"] : "" 
  message_key = env['omniauth.error.type']
  error_param = env['omniauth.error'] && env['omniauth.error'].respond_to?("error") ? "&error=" + env['omniauth.error'].error : ""
  error_reason_param ||= env['omniauth.error'] && env['omniauth.error'].respond_to?("error_reason") ? "&error_reason=" + env['omniauth.error'].error_reason : ""
  origin_query_param = env['omniauth.origin'] ? "&origin=#{Rack::Utils.escape(env['omniauth.origin'])}" : ""
  strategy_name_query_param = env['omniauth.error.strategy'] ? "&strategy=#{env['omniauth.error.strategy'].name}" : ""
  new_path = "#{OmniAuth.config.path_prefix}/failure?message=#{message_key}#{origin_query_param}#{strategy_name_query_param}#{error_param}#{error_reason_param}"
  [302, {'Location' => new_path, 'Content-Type'=> 'text/html'}, []]
end