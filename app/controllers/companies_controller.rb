class CompaniesController < ApplicationController

  hobo_model_controller

  auto_actions :all
    
  autocomplete :users do
    ret = []
    users = find_instance.users.each { |user| 
      ret << user.name.to_s + " (" + user.email_address.to_s + ")"
    }
    render :json => ret
  end
  
  include RestController
  
  show_action :collaborators
    
  def first
    hobo_new
  end
  
  def show
    current_user.all_companies.load
    current_user.all_hoshins.load
    self.this = Company.includes(:hoshins).user_find(current_user, params[:id])
    hobo_show
  end
  
  def collaborators
    @this = find_instance
    if @this.plan == 'PENDING'
      flash.now[:warning] = t("pricing_plans.pending").html_safe 
    else
      flash.now[:info] = t("errors.user_limit_reached").html_safe if @this.collaborator_limits_reached?
    end
    if (@this.plan == 'basic' || @this.plan.blank?) 
      session[:payment_return_to] = request.url
      render template: 'payments/pricing'
    end
    @collaborators = cols
  end
  
  def cols
    find_instance.user_companies.joins(:user)
          .where("email_address like ? or name like ?", "%"+params[:search].to_s+"%", "%"+params[:search].to_s+"%")
          .order_by(parse_sort_param(:state, :user => "name || email_address"))
          .paginate(:page => params[:page], :per_page => 15).load
  end
  
  def create
    hobo_create
    log_event("Create company", {objid: @this.id, name: @this.name})
  end

  def destroy
    hobo_destroy do
      redirect_to "/" if valid? && !request.xhr?
    end
    log_event("Delete company", {objid: @this.id, name: @this.name})
  end
  
  def update
    if params[:collaborators]
      error = false
      begin
        params[:collaborators].each_line do |email|
          email.squish! 
          user = User.unscoped.where(:email_address => email).first
          if user.nil?
            domain = email.split("@").last
            if (domain == "infojobs.net" || domain == "lectiva.com")
              user = User::Lifecycle.activate_ij(:email_address => email)
              user.email_address = email
              user.save!(:validate => false)
            else
              user = User::Lifecycle.invite(:email_address => email)
              user.email_address = email
              user.save!(:validate => false)
            end
          end
          uc = UserCompany.where(:company_id => params[:id], :user_id => user.id).first
          if uc.nil? 
            company = Company.find(params[:id])
            begin
              if (domain == "infojobs.net" || domain == "lectiva.com")
                UserCompany::Lifecycle.activate_ij(current_user, {:user => user, :company => company})
              else
                UserCompany::Lifecycle.invite(current_user, {:user => user, :company => company})
              end
            rescue Hobo::PermissionDeniedError => e
              flash[:error] = t("errors.user_limit_reached").html_safe
              redirect_to @this, :action => :collaborators
              return
            end
          end
        end
        @this = find_instance
        redirect_to @this, :action => :collaborators unless error
        log_event("Invite collaborators", {objid: @this.id, name: @this.name}) unless error
        #rescue Exception => e
        #redirect_to Company.find(params[:id]), {:action => :edit, :error => e }
      end
    else
      hobo_update
      log_event("Update company", {objid: @this.id, name: @this.name})
      
    end
  end
  

end
