class ClientApplicationsController < ApplicationController
  require 'uri'
  
  hobo_model_controller

  auto_actions :all
  
  show_action :sign do
    timestamp = Time.new.xmlschema
    data =  params[:data] + "&timestamp=" + CGI::escape(timestamp.to_s)
    signature = find_instance.sign(data)
    render :json => "alert('" + data + "&signature=" + signature + "');"
  end

end
