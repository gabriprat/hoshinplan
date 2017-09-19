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

  def show
    @this = User.unscoped.find(params[:id])
    hobo_show
  end

  def edit
    @this = User.unscoped.find(params[:id])
    hobo_edit
  end

  def update
    @this = User.unscoped.find(params[:id])
    if params[:user][:password].present?
      @this.update_attribute(:crypted_password, nil) # No validations
      @this.update_attribute(:salt, nil) # No validations
      @this.password = params[:user][:password]
      @this.save!(validate: false) #Password validation would fail
    end
    params[:user].delete(:password)
    hobo_update
  end

  def supplant
    self.current_user = find_instance
    redirect_to home_page
  end
  
  def index
    if params[:search].present?
      @users = Hobo.find_by_search(params[:search], [User.unscoped])[User.name]
      @users ||= User.where('1=0')
    else
      @users = User.unscoped.all
    end

    sort = parse_sort_param(:name, :email_address, :id, :created_at, :administrator, :timezone, :state, :email_address, :preferred_view, :language)
    sort ||= '-id'
    @users = @users.order_by(sort).paginate(:page => params[:page], :per_page => 15).load
    hobo_index
  end
  
  
end