class User < ActiveRecord::Base

  include ModelBase
  
  
  hobo_user_model # Don't put anything above this
  
  NEXT_FRIDAY = DateTime.now.next_week.next_day(4)
  
  include HoboOmniauth::MultiAuth
  
  fields do
    name          :string, :required
    email_address :email_address, :login => true
    administrator :boolean, :default => false
    tutorial_step :integer
    timezone      HoboFields::Types::Timezone
    timestamps
  end
  bitmask :tutorial_step, :as => [:company, :hoshin, :goal, :area, :objective, :indicator, :task, :followup]

  has_attached_file :image, :styles => {
    :thumb => "104x104#" },
    :default_url => "/assets/default.jpg"
  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/
  #validates_attachment_size :image, :less_than => 10.megabytes    
    
  attr_accessible :name, :email_address, :password, :password_confirmation, :companies, :image, :timezone
  
  has_many :hoshins, :through => :companies
  has_many :objectives, :dependent => :nullify, :inverse_of => :responsible, foreign_key: :responsible_id
  has_many :indicators, :dependent => :nullify, :inverse_of => :responsible, foreign_key: :responsible_id
  has_many :indicator_histories, :through => :indicators
  has_many :tasks, :dependent => :nullify, :inverse_of => :responsible, foreign_key: :responsible_id
  has_many :companies, :through => :user_companies, :accessible => true
  has_many :user_companies, :dependent => :destroy 
  has_many :authorizations, :dependent => :destroy
  has_many :client_applications, :dependent => :destroy
  
  has_many :my_companies, :class_name => "Company", :inverse_of => :creator, :foreign_key => :creator_id
  has_many :my_hoshins, :class_name => "Hoshin", :inverse_of => :creator, :foreign_key => :creator_id
  has_many :my_areas, :class_name => "Area", :inverse_of => :creator, :foreign_key => :creator_id
  has_many :my_goals, :class_name => "Goal", :inverse_of => :creator, :foreign_key => :creator_id
  has_many :my_objectives, :class_name => "Objective", :inverse_of => :creator, :foreign_key => :creator_id
  has_many :my_tasks, :class_name => "Task", :inverse_of => :creator, :foreign_key => :creator_id
  has_many :my_indicators, :class_name => "Indicator", :inverse_of => :creator, :foreign_key => :creator_id
  has_many :my_indicator_histories, :class_name => "IndicatorHistory", :inverse_of => :creator, :foreign_key => :creator_id
    
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
       
  TODAY_SQL = "date_trunc('day',now() at time zone coalesce(timezone, current_setting('TIMEZONE')))"
  
  scope :at_hour, lambda { |*hour|
    where("date_part('hour',current_time at time zone coalesce(timezone, current_setting('TIMEZONE'))) = ?", hour) 
  }
  
  scope :task_reminders, lambda { 
    joins(:indicators)
    .where('reminder = true and next_update between current_date-5 and current_date')
  }

  def next_tutorial
    ret = (User.values_for_tutorial_step - tutorial_step).first
    ret.nil? ? [] : ret 
  end
  
  # --- Signup lifecycle --- #

  lifecycle do

    state :inactive, :default => true
    state :invited
    state :active
    
    create :from_omniauth, :params => [:name, :email_address], :become => :active do
      domain = self.email_address.split("@").last
      if (domain == "infojobs.net" || domain == "lectiva.com")
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
      
    create :activate_ij,
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
    Hoshin.unscoped.select("hoshins.*, companies.name as company_name").joins(:company).where(:company_id => UserCompany.unscoped.select(:company_id).where('user_id = ?', self.id))
  end

  def signed_up?
    state=="active" || state=="invited"
  end
  
  def account_active?
    signed_up?
  end
  
  def self.current_id=(id)
    RequestStore.store[:client_id] = id
  end

  def self.current_id
    RequestStore.store[:client_id]
  end  
  
  def self.current_user
    ret = RequestStore.store[:user]
    if (ret.nil? && !self.current_id.nil?) 
      ret = User.find(self.current_id)
      RequestStore.store[:user] = ret
    end
    ret
  end
  
  def dashboard
    Company.current_id = nil
    {
        "indicators" => Indicator.where("next_update < ? and responsible_id = ?", NEXT_FRIDAY, self.id).order("next_update ASC"),
        "tasks" => Task.where("deadline < ? and responsible_id = ? and status = 'active'", NEXT_FRIDAY, self.id).order("deadline ASC")
    }
  end
  
  # --- Permissions --- #

  def create_permitted?
    # Only the initial admin user can be created
    self.class.count == 0
  end

  def update_permitted?     
    f = none_changed?(:administrator)
    acting_user.administrator? or
      ((acting_user == self or same_company_admin) && f)
    # Note: crypted_password has attr_protected so although it is permitted to change, it cannot be changed
    # directly from a form submission.
  end

  def destroy_permitted?
    acting_user == self || acting_user.administrator?
  end
  
  def same_company 
    acting_user == self || acting_user.user_companies.where(:company_id => self.user_companies.*.company_id).present?
  end
  
  def same_company_admin
     acting_user.user_companies.where(:state => :admin, :company_id => self.user_companies.*.company_id).present?
  end

  def view_permitted?(field)
    # permit password fields to avoid the reset password page to fail
    field == :password || field == :password_confirmation || acting_user.administrator? || self.new_record? || self.guest? || same_company
  end
end
