class UserCompany < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do 
    timestamps
  end
  attr_accessible :company, :company_id, :user, :user_id
  
  belongs_to  :company, :accessible => true
  belongs_to  :user, :accessible => true
 
  #validate :company_admin_validator
  
  default_scope lambda { 
    where("company_id = ? or ? is null", Company.current_id, Company.current_id) }
  
  def company_admin_validator
    if acting_user.nil?
      errors.add(:company, "you have to be logged in" ) 
    else
      errors.add(:company, "you must be an administrator of \"" + company.name + 
        "\" to be able to associate users to it.") unless company_admin || new_company_available
    end
  end
  
  def company_admin
    self.company.nil? || #!self.company_changed? ||
    acting_user.user_companies.company_is(self.company).state_is(:admin).exists?
  end
  
  def company_admin_available
    acting_user if company_admin
  end
  
  def accept_available
    return false unless self.lifecycle.valid_key?
    return self.user
  end
 
  new_company_available = Proc.new do |r|
    acting_user if r.company.user_companies.empty?
  end
  
  
  lifecycle do

     state :invited, :active, :admin

     create :invite, :params => [ :company, :user ], :become => :invited,
                      :available_to => "User", :new_key => true do
       UserCompanyMailer.invite(self, "Join me at #{company.name} Hoshin Plan", 
         "#{acting_user.name} wants to invite you to collaborate to their Hoshin Plan.",
         "By accepting this invitation you will be able to participate in the Hoshin plan of their company: #{company.name}.",
         "Accept",
         lifecycle.key, acting_user).deliver
     end
     
     transition :resend_invite, { :invited => :invited }, :available_to => :company_admin_available, :new_key => true do
           UserCompanyMailer.invite(self, "Invitation to the Hoshin Plan of #{company.name}", 
             "#{acting_user.name} wants to invite you to collaborate to their Hoshin Plan.",
             "By accepting this invitation you will be able to participate in the Hoshin plan of their company: #{company.name}.",
             "Accept",
             lifecycle.key).deliver
     end
     
     create :new_company, :params => [ :company, :user ], :become => :admin
     
     transition :accept, { :invited => :active }, :available_to => :accept_available do
       #user = self.user
       #user.lifecycle.activate!(user)
       #user.save!(:validate => false)
       company.user_companies.where(:state => :admin).each do |admin| 
         UserCompanyMailer.transition(admin.user, "Invitation accepted!", 
         "#{user.email_address} is now collaborating to the Hoshinplan of #{company.name}").deliver
       end
     end

     transition :cancel_invitation, { :invited => :destroy }, :available_to => :company_admin_available 

     transition :make_admin, { :active => :admin }, :available_to => :company_admin_available do
       self.save!
       UserCompanyMailer.transition(user, "Administrator", 
       "#{user.name}, you are now administrating the Hoshinplan of #{company.name}").deliver
     end
     
     transition :revoke_admin, { :admin => :active }, :available_to => :company_admin_available do
       self.save!
       UserCompanyMailer.transition(user, "You are no longer administrator", 
       "#{acting_user.name} has revoked your administration rights to the Hoshinplan of #{company.name}").deliver
     end
 
     transition :remove, { UserCompany::Lifecycle.states.keys => :destroy }, :available_to => :company_admin_available do
       UserCompanyMailer.transition(user, "Colaboration canceled", 
       "#{acting_user.name} cancelled your collaboration to the Hoshinplan of #{company.name}").deliver
     end

   end

  # --- Permissions --- #

  def create_permitted?
    true
  end

  def update_permitted?
    acting_user.administrator? || acting_user.user_companies.company_is(company).where(:state => :admin).exists?
  end

  def destroy_permitted?
    acting_user.administrator? || acting_user.user_companies.company_is(company).where(:state => :admin).exists?
  end

  def view_permitted?(field)
    true
  end

end
