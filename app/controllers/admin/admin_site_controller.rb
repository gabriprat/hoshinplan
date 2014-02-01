class Admin::AdminSiteController < ApplicationController
  
  hobo_controller
  
  include_taglib 'admin'

  # require administrator to access any controller in the sub-site
  before_filter :admin_required
  def admin_required
    redirect_to login_url unless logged_in? && current_user.administrator?
  end

  # the default page when visiting the sub-site
  def index
    redirect_to '/admin/users'
  end
end
