class CompaniesController < ApplicationController

  hobo_model_controller

  auto_actions :all
  
  web_method :checkout
    
  autocomplete :users do
    ret = []
    users = find_instance.users.each { |user| 
      ret << user.name.to_s + " (" + user.email_address.to_s + ")"
    }
    render :json => ret
  end
  
  autocomplete :users2 do
    ret = {}
    users = find_instance.users.each { |user| 
      ret[user.id] = user.name.to_s + " (" + user.email_address.to_s + ")"
    }
    render :json => ret
  end
  
  include RestController
  
  show_action :collaborators
  show_action :upgrade
  web_method  :invite
  
  def_param_group :company do
    param :name, String
  end
    
  def first
    hobo_new
  end
  
  api :GET, '/companies/:id', 'Get a company'
  def show
    current_user.all_companies
    self.this ||= find_instance
    self.this.same_company_admin # load request variable to aviod queries in the template
    @active = Hoshin.arrange_nodes(self.this.hoshins.active.includes(:creator).ordered_by_ancestry)
    @archived = Hoshin.arrange_nodes(self.this.hoshins.archived.includes(:creator).ordered_by_ancestry)
    hobo_show
  end
  
  def collaborators
    @freq = params[:freq]
    @freq ||= :MONTH
    current_user.all_companies
    @this = Company.user_find(current_user, params[:id])
    @this.same_company_admin # load request variable to avoid queries in the template
    @limit_reached = false
    @collaborators = cols
    if @this.collaborator_limits_reached?
      @limit_reached = true
      flash.now[:info] = t("errors.user_limit_reached").html_safe 
      @billing_plans = BillingPlan.where(frequency: [:WEEK, @freq]).where.not(position: 1)
    end
  end
  
  def upgrade
    if find_instance.same_company_admin
      @freq = params[:freq]
      @freq ||= :MONTH
      @this = BillingPlan.where(frequency: [:WEEK, @freq]).where.not(position: 1)
      session[:payment_return_to] = request.url
      if params[:trial_expired].present? && params[:trial_expired]
        flash.now[:error] = I18n.t "payments.expired_trial"
      end
      render template: 'payments/pricing'
    else
      render template: 'payments/contact_admin'
    end
    log_event("Pricing page view")
  end
  
  def invite
    @this = find_instance
  end
  
  def cols
    order = parse_sort_param(:state => "user_companies.state", :user => "lower(coalesce(users.\"firstName\",'') || coalesce(users.\"lastName\",'') || email_address)")
    order ||= "lower(coalesce(users.\"firstName\",'') || coalesce(users.\"lastName\",'') || email_address)"
    find_instance.user_companies.includes(:user).references(:user)
          .where("email_address like ? or name like ?", "%"+params[:search].to_s+"%", "%"+params[:search].to_s+"%")
          .order_by(order)
          .paginate(:page => params[:page], :per_page => 15).load
  end
  
  api :POST, '/companies', 'Create a company'
  param_group :company
  def create
    hobo_create
    log_event("Create company", {objid: @this.id, name: @this.name})
  end

  api :DELETE, '/companies/:id', 'Delete a company'
  param_group :company
  def destroy
    hobo_destroy do
      redirect_to "/" if valid? && !request.xhr?
    end
    log_event("Delete company", {objid: @this.id, name: @this.name})
  end
  
  api :PUT, '/companies/:id', 'Update a company'
  param_group :company
  def update
    roles = [params[:role]]
    if params[:collaborators]
      error = false
      invite_sent = false
      begin
        params[:collaborators].split(",").each do |email|
          email.strip!
          email.downcase! 
          arr = email.split(/[ <>"]/)
          email = arr.pop
          if (arr.present?)
            case 
            when arr.size==1
              firstName = arr.shift
            when arr.size==2
              firstName = arr.shift
              lastName = arr.shift
            when arr.size==3
              firstName = arr.shift
              lastName = arr.join(" ")
            when arr.size>3
              firstName = arr[0..1].join(" ")
              lastName = arr[2..arr.size].join(" ")
            end
          end
          user = User.unscoped.where(:email_address => email).first
          domain = email.split("@").last
          company_domain_exists = CompanyEmailDomain.where(domain: domain, company_id: params[:id]).exists?
          if user.nil?            
              user = User::Lifecycle.invite(current_user, {:email_address => email})
              invite_sent = true
              user.email_address = email
              user.firstName = firstName if firstName.present?
              user.lastName = lastName if lastName.present?
              begin
                user.save!
              rescue ActiveRecord::RecordInvalid => invalid
                
                flash[:error] = (flash[:error].nil? ? '' :  flash[:error] + ", ") + user.errors.full_messages.first + " (" + email + ")"
              end
          end
          uc = UserCompany.where(:company_id => params[:id], :user_id => user.id).first
          if uc.nil? 
            company = Company.find(params[:id])
            begin
              if (company_domain_exists)
                UserCompany::Lifecycle.activate_ij(current_user, {:user => user, :company => company, :roles => roles})
              else
                if invite_sent
                  UserCompany::Lifecycle.invite_without_email(current_user, {:user => user, :company => company, :roles => roles})
                else
                  UserCompany::Lifecycle.invite(current_user, {:user => user, :company => company, :roles => roles})
                end
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
