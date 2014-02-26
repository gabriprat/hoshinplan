class User < ActiveRecord::Base

  hobo_user_model # Don't put anything above this
  
  NEXT_FRIDAY = DateTime.now.next_week.next_day(4)
  
  include HoboOmniauth::MultiAuth
  
  fields do
    name          :string, :required
    email_address :email_address, :login => true
    image         HoboFields::Types::ImageUrl
    administrator :boolean, :default => false
    timestamps
  end
  attr_accessible :name, :email_address, :password, :password_confirmation, :companies, :image
  
  has_many :hoshins, :through => :companies
  has_many :objectives, :dependent => :destroy, :inverse_of => :responsible, foreign_key: :responsible_id
  has_many :indicators, :dependent => :destroy, :inverse_of => :responsible, foreign_key: :responsible_id
  has_many :tasks, :dependent => :destroy, :inverse_of => :responsible, foreign_key: :responsible_id
  has_many :companies, :through => :user_companies, :accessible => true
  has_many :user_companies, :dependent => :destroy 
  has_many :authorizations, :dependent => :destroy
  has_many :client_applications, :dependent => :destroy
    
  # This gives admin rights and an :active state to the first sign-up.
  before_create do |user|
    if user.class.count == 0
      user.administrator = true
    end
  end
  
  default_scope lambda { 
    where(:id => UserCompany.select(:user_id)
      .where('company_id=?',  
        Company.current_id) ) unless Company.current_id.nil? }

  # --- Signup lifecycle --- #

  lifecycle do

    state :inactive, :default => true
    state :invited
    state :active
    
    create :from_omniauth, :params => [:name, :email_address], :become => :active do
      if (self.email_address.split("@").last == "infojobs.net")
        self.companies = [Company.find(1)]
      else
        @subject = "#{self.name} welcome to Hoshinplan!"
        UserCompanyMailer.welcome(self, 
        @subject).deliver
      end
    end

    create :invite,
      :params => [:name, :email_address, :password, :password_confirmation],
      :become => :invited
      
    create :active_ij,
        :params => [:name, :email_address, :password, :password_confirmation],
        :become => :active
    
    create :signup, :available_to => "Guest",
      :params => [:name, :email_address, :password, :password_confirmation],
      :become => :inactive, :new_key => true  do
      UserMailer.activation(self, lifecycle.key).deliver
    end

    transition :activate, { :inactive => :active }, :available_to => :key_holder do
      @subject = "#{self.name} welcome to Hoshinplan!"
      UserCompanyMailer.welcome(self, 
      @subject).deliver
    end

    transition :activate, { :invited => :active } do
      @subject = "#{self.name} welcome to Hoshinplan!"
      UserCompanyMailer.invited_welcome(self, 
      @subject).deliver
    end

    transition :request_password_reset, { :inactive => :inactive }, :new_key => true do
      UserMailer.activation(self, lifecycle.key).deliver
    end

    transition :request_password_reset, { :active => :active }, :new_key => true do
      UserMailer.forgot_password(self, lifecycle.key).deliver
    end

    transition :reset_password, { :active => :active }, :available_to => :key_holder,
               :params => [ :password, :password_confirmation ]

  end
  
  def all_companies
    Company.unscoped.where(:id => UserCompany.unscoped.select(:company_id).where('user_id = ?', self.id))
  end
  
  def all_hoshins
    Hoshin.unscoped.where(:company_id => UserCompany.unscoped.select(:company_id).where('user_id = ?', self.id))
  end

  def signed_up?
    state=="active" || state=="invited"
  end
  
  def account_active?
    signed_up?
  end
  
  def self.current_id=(id)
    Thread.current[:client_id] = id
  end

  def self.current_id
    Thread.current[:client_id]
  end  
  
  def dashboard
    Company.current_id = nil
    {
        "indicators" => self.indicators.unscoped.where("next_update < ? and responsible_id = ?", NEXT_FRIDAY, self.id).order("next_update ASC"),
        "tasks" => self.tasks.unscoped.where("deadline < ? and responsible_id = ? and status = 'active'", NEXT_FRIDAY, self.id).order("deadline ASC")
        }
  end
  
  # --- Permissions --- #

  def create_permitted?
    # Only the initial admin user can be created
    self.class.count == 0
  end

  def update_permitted?
    f = only_changed?(:name, :email_address, :crypted_password,
                                            :current_password, :password, :password_confirmation)
    acting_user.administrator? or
      ((acting_user == self or same_company_admin) && f)
    # Note: crypted_password has attr_protected so although it is permitted to change, it cannot be changed
    # directly from a form submission.
  end

  def destroy_permitted?
    acting_user.administrator?
  end
  
  def same_company 
    acting_user == self || acting_user.user_companies.where(:company_id => self.user_companies.*.company_id).present?
  end
  
  def same_company_admin
     acting_user.user_companies.where(:state => :admin, :company_id => self.user_companies.*.company_id).present?
  end

  def view_permitted?(field)
    acting_user.administrator? or same_company
  end
end
