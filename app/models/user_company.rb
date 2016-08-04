class UserCompany < ActiveRecord::Base

  IS_ADMIN_SQL = 'roles_mask & 4 != 0';

  include ModelBase
  
  
  hobo_model # Don't put anything above this

  fields do
    roles_mask :integer, null: false, default: 3
    timestamps
  end

  include RoleModel
  # declare the valid roles -- do not change the order if you add more
  # roles later, always append them at the end!
  roles [:reader, :editor, :admin]

  attr_accessible :company, :company_id, :user, :user_id, :roles
  index [:user_id, :company_id]
  
  belongs_to  :company, :accessible => true
  belongs_to  :user, :accessible => true
 
  #validate :company_admin_validator
  
  default_scope lambda { 
    where(company_id: UserCompany.select(:company_id).where('user_id=?', User.current_id)) unless !User.current_user.nil? && User.current_user.respond_to?("administrator?") && User.current_user.administrator? 
  }
 
  scope :by_cname, lambda {
    includes(:company).references(:company).order('companies.name')
  }
  
  def company_admin_validator
    if acting_user.nil?
      errors.add(:company, "you have to be logged in" ) 
    else
      errors.add(:company, "you must be an administrator of \"" + company.name + 
        "\" to be able to associate users to it.") unless same_company_admin || new_company_available
    end
  end
  
  before_destroy do |uc|
    Indicator.where(:company_id => uc.company_id, :responsible_id => uc.user_id).update_all(:responsible_id => nil)
    Task.where(:company_id => uc.company_id, :responsible_id => uc.user_id).update_all(:responsible_id => nil)
  end

  before_save do |uc|
    if uc.roles_mask == 2
      uc.roles_mask = 3 #Editor implies reader
    end

    if uc.roles_mask == 4
      uc.roles_mask = 7 #Admin implies editor and reader
    end
  end
  
  def company_admin_available
    acting_user if same_company_admin
  end
  
  def accept_available 
    return false unless self.lifecycle.valid_key?
    return self.user
  end
 
  new_company_available = Proc.new do |r|
    acting_user if r.company.user_companies.empty?
  end
  
  def activate_ij_available
    ret = create_available
    domain = self.user.email_address.split("@").last 
    return ret if CompanyEmailDomain.where(domain: domain, company_id: self.company_id).exists?
  end
  
  def create_available
    return acting_user if create_permitted?
  end
  
  def activate_available
    return acting_user if user_id == acting_user.id || same_company_admin 
  end
  
  lifecycle do

     state :invited, :active

     create :invite, :params => [ :company, :user, :roles ], :become => :invited,
                      :available_to => :create_available, :new_key => true do
         UserCompanyMailer.invite(self, company, lifecycle.key, acting_user, acting_user.language.to_s).deliver_later
     end
     
     create :invite_without_email, :params => [ :company, :user, :roles ], :become => :invited,
                      :available_to => :create_available, :new_key => true
     
     create :activate_ij, :params => [ :company, :user, :roles ], :become => :active, :available_to => :activate_ij_available

     transition :activate, {:invited => :active}, :available_to => :activate_available

     transition :resend_invite, { :invited => :invited }, :available_to => :company_admin_available, :new_key => true do
       if self.user.state == "invited"
         self.user.lifecycle.resend_invite!(acting_user)
       else
         UserCompanyMailer.invite(self, company, lifecycle.key, acting_user, acting_user.language.to_s).deliver_later
       end
     end
     
     create :new_company, :params => [ :company, :user ], :become => :active do
       self.roles << :admin
     end
     
     transition :accept, { :invited => :active }, :available_to => :accept_available do
       #user = self.user
       #user.lifecycle.activate!(user)
       #user.save!(:validate => false)
       company.user_companies.where(IS_ADMIN_SQL).each do |admin|
         UserCompanyMailer.transition(admin.user, user, company, 'accept').deliver_later
       end
     end
     
     transition :cancel_invitation, { :invited => :destroy }, :available_to => :company_admin_available
 
     transition :remove, { UserCompany::Lifecycle.states.keys => :destroy }, :available_to => :company_admin_available do 
       UserCompanyMailer.transition(User.unscoped.find(self.user_id), acting_user, company, "removed").deliver_later
       Objective.where(:responsible_id => user_id, :company_id => company_id).update_all(:responsible_id => nil)
       Indicator.where(:responsible_id => user_id, :company_id => company_id).update_all(:responsible_id => nil)
       Task.where(:responsible_id => user_id, :company_id => company_id).update_all(:responsible_id => nil)
      end

   end

  # --- Permissions --- #

  def create_permitted?
    return true unless company_id
    company = Company.unscoped.find(company_id)
    !company.collaborator_limits_reached?
  end

  def update_permitted?
    acting_user.administrator? || acting_user.user_companies.where('company_id = ? and ' + IS_ADMIN_SQL, company_id).exists?
  end

  def destroy_permitted?
    return false if user_id == 557 && !acting_user.administrator?
    user_id == acting_user.id || acting_user.administrator? || acting_user.user_companies.where('company_id = ? and ' + IS_ADMIN_SQL, company_id).exists?
  end

  def view_permitted?(field)
    true
  end

end
