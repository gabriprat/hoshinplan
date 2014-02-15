class CmsController < ApplicationController
  require 'net/http'

  hobo_controller
  
  include CmsHelper

  def show 
    key = params["key"]
    @this = cmsGet(key)
    @key = key
  end  
  
  def expire
    expire_action :action => :show
    redirect_to :action => :show
  end
end