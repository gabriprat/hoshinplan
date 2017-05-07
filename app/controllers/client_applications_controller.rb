class ClientApplicationsController < ApplicationController
  require 'uri'
  
  hobo_model_controller

  auto_actions :all
  
  web_method :sign

  def sign
    @uri = params[:uri]
    @uri += "?app_key=#{params[:key]}" unless @uri.include? '?'
    @signed = find_instance.sign_uri(@uri)
    hobo_ajax_response
  end

end
