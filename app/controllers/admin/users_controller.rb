class Admin::UsersController < Admin::AdminSiteController

  hobo_user_controller
  
  auto_actions :index, :edit, :destroy, :update, :show
  
  index_action :suplist
  
  web_method :supplant
  
  def suplist
    users = model.all
    @this = { "guest" => 0 }
    users.each { |u| 
      @this[u.login.to_s] = u.id 
    }
  end
  
  def supplant
    self.current_user = find_instance
    redirect_to home_page
  end
  
  def index
    @users = model.search(params[:search], :email_address).
     order_by(parse_sort_param(:name, :email_address)).paginate(:page => params[:page], :per_page => 15).all
    hobo_index
  end
  
  
end