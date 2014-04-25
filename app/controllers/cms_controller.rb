class CmsController < ApplicationController
  require 'net/http'

  hobo_controller
  
  include CmsHelper

  def show 
    @key = params["key"]
  end  
  
end