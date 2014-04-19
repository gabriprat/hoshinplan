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