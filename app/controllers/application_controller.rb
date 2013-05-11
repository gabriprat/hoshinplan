class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :my_login_required,  :except => [:index, :login, :signup, :activate,
         :do_activate, :do_signup, :forgot_password, :reset_password,
         :do_reset_password]
  
  # We provide our own method to call the Hobo helper here, so we can check the 
  # User count. 
  def my_login_required
    return true if logged_in?
    flash[:warning]='Please login to continue'
    session[:return_to] = request.url
    redirect_to "/auth/google_oauth2"
    return false 
     
  end
end

 def login_required
    if session[:user]
      return true
    end
    flash[:warning]='Please login to continue'
    session[:return_to]=request.request_uri
    redirect_to "/auth/google_oauth2"
    return false 
  end