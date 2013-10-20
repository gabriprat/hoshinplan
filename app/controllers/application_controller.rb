class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :my_login_required,  :except => [:index, :login, :signup, :activate,
         :do_activate, :do_signup, :forgot_password, :reset_password,
         :do_reset_password, :mail_preview]
         
         around_filter :scope_current_user  

             def scope_current_user
                 if defined?("logged_in?")
                 User.current_id = logged_in? ? current_user.id : nil
                 if !params[:id].nil?
                   inst = find_instance unless params[:id].nil?
                   if inst.respond_to?(:company_id)
                     Company.current_id = inst.company_id
                   end
                 elsif !params[:company_id].nil?
                   Company.current_id = Company.find(params[:company_id]).id
                 end
                 end
             yield
             ensure
                 #avoids issues when an exception is raised, to clear the current_id
                 User.current_id = nil   
                 Company.current_id = nil    
             end
             
  before_filter :action_mailer_init
  
  def action_mailer_init
    ActionMailer::Base.default_url_options = {:host => request.host_with_port}
    ActionMailer::Base.default_url_options[:only_path] = false
  end

  
  # We provide our own method to call the Hobo helper here, so we can check the 
  # User count. 
  def my_login_required
    #return false if !defined?(logged_in)
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
  
  