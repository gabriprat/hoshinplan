class UriDirReportsController < ApplicationController

  hobo_model_controller

  auto_actions :all
  
  def create
    i = model.new
    i.body = request.body.read
    hobo_create i
  end

end
