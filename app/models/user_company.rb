class UserCompany < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do 
    administrator    :boolean, :default => false
    timestamps
  end
  attr_accessible :administrator, :company, :company_id, :user, :user_id
  
  belongs_to  :company, :accessible => true
  belongs_to  :user, :accessible => true
 
  validate :company_admin_validator
  
  
  def company_admin_validator
    if acting_user.nil?
      #errors.add(:company, "you have to be logged in" ) 
    else
      errors.add(:company, "you must be an administrator of \"" + company.name + 
        "\" to be able to associate users to it.") unless company_admin
    end
  end
  
  def company_admin
    self.company.nil? || !self.company_changed? ||
    acting_user.user_companies.company_is(self.company).state_is(:admin).exists?
  end
  
  def company_admin_available
    acting_user if company_admin
  end
 
 
  new_company_available = Proc.new do |r|
    acting_user if r.company.user_companies.empty?
  end
  
  
  lifecycle do

     state :invited, :active, :admin

     create :invite, :params => [ :company, :user ], :become => :invited,
                      :available_to => "User", :new_key => true do
       UserCompanyMailer.invite(self, "Invitation to collaborate", 
         "#{acting_user.name} wants to invite you to collaborate to the Hoshinplan of #{company.name}.",
         lifecycle.key,).deliver
     end
     
     create :new_company, :params => [ :company, :user ], :become => :admin
     
     transition :accept, { :invited => :active }, :available_to => :key_holder do
       acting_user.lifecycle.activate!(acting_user)
       acting_user.save!(:validate => false)
       company.user_companies.administrator.each do |admin| 
         UserCompanyMailer.transition(admin.user, "Invitation accepted!", 
         "#{user.name} is now collaborating to the Hoshinplan of #{company.name}").deliver
       end
     end

     transition :reject, { :invited => :destroy }, :available_to => :company_admin_available 

     transition :admin, { :active => :admin }, :available_to => :company_admin_available do
       UserCompanyMailer.transition(user, "Administrator", 
       "#{acting_user.name}, you are now administrating the Hoshinplan of #{company.name}").deliver
     end
 
     transition :cancel, { :active => :destroy }, :available_to => :company_admin_available do
       UserCompanyMailer.transition(user, "Colaboration canceled", 
       "#{acting_user.name} cancelled your collaboration to the Hoshinplan of #{company.name}").deliver
     end

   end

  # --- Permissions --- #

  def create_permitted?
    true
  end

  def update_permitted?
    acting_user.administrator? || acting_user.user_companies.company_is(company).administrator.exists?
  end

  def destroy_permitted?
    acting_user.administrator? || acting_user.user_companies.company_is(company).administrator.exists?
  end

  def view_permitted?(field)
    true
  end

end
