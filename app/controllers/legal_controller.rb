class LegalController < ApplicationController

  hobo_controller 
  
  # Public controller
  skip_before_filter :my_login_required
  
  def show
  end

end