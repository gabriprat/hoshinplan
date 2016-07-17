class Admin::UsersController < Admin::AdminSiteController

  hobo_user_controller
  
  auto_actions :index, :edit, :destroy, :update, :show, :new, :create
  
  index_action :suplist
  
  web_method :supplant
  
  def suplist
    users = model.load
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
    @users = Hobo.find_by_search(params[:search], [User])[User.name] if params[:search].present?

    @users ||= User.all

    @users = @users.order_by(parse_sort_param(:name, :email_address, :id, :created_at, :administrator, :timezone, :state, :email_address, :preferred_view, :language)).paginate(:page => params[:page], :per_page => 15).load
    hobo_index
  end
  
  
end