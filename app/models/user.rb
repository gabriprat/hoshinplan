class User < ActiveRecord::Base

  include ModelBase
  include ColorHelper
  
  hobo_user_model # Don't put anything above this
  
  NEXT_FRIDAY = DateTime.now.next_week.next_day(4)
  
  include HoboOmniauth::MultiAuth
  
  fields do
    name          :string
    firstName     :string
    lastName      :string
    color         Color
    email_address :email_address, :login => true, :index => true, :unique => true
    administrator :boolean, :default => false
    tutorial_step :integer
    timezone      HoboFields::Types::Timezone
    timestamps
    language      EnumLanguage
    last_seen_at  :date
    last_login_at :datetime
    login_count   :integer
    payments_count :integer, :default => 0, :null => false
    preferred_view EnumView, :required, :default=> :compact
  end
  bitmask :tutorial_step, :as => [:company, :hoshin, :goal, :area, :objective, :indicator, :task, :followup]

  has_attached_file :image, {
    :styles => {
      :thumb4x => "416x416#",
      :thumb3x => "312x312#",
      :thumb2x => "208x208#",
      :thumb => "104x104#",
      :mini4x => "116x116#",
      :mini3x => "87x87#",
      :mini2x => "58x58#",
      :mini => "29x29#"
    },
    :convert_options => {
      :mini => "-quality 80 -interlace Plane",
      :mini2x => "-quality 80 -interlace Plane",
      :mini3x => "-quality 80 -interlace Plane",
      :mini4x => "-quality 80 -interlace Plane",
      :thumb => "-quality 80 -interlace Plane",
      :thumb2x => "-quality 80 -interlace Plane",
      :thumb3x => "-quality 80 -interlace Plane",
      :thumb4x => "-quality 80 -interlace Plane"
    },
    :s3_headers => { 
      'Cache-Control' => 'public, max-age=315576000', 
      'Expires' => 10.years.from_now.httpdate 
    },
    :default_url => "/assets/default.jpg"
  }
  
  before_save do |user|
    if user.name.blank?
      n = user.email_address.split('@')[0]
      user.name = n.split(".").join(" ").titleize
    end
  end
  
  validates :email_address, uniqueness: { case_sensitive: false }
  
  #validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/
  #validates_attachment_size :image, :less_than => 10.megabytes   
  validates_attachment :image, content_type: { content_type: ["image/jpg", "image/jpeg", "image/png", "image/gif"] } 
    
  attr_accessible :firstName, :lastName, :email_address, :password, :password_confirmation, :companies, :image, :timezone, :tutorial_step, :created_at, :language
  
  has_many :hoshins, :through => :companies
  has_many :objectives, :dependent => :nullify, :inverse_of => :responsible, foreign_key: :responsible_id
  has_many :indicators, -> { order :next_update }, :dependent => :nullify, :inverse_of => :responsible, foreign_key: :responsible_id
  has_many :indicator_histories, :through => :indicators
  has_many :tasks,  -> { order :deadline }, :dependent => :nullify, :inverse_of => :responsible, foreign_key: :responsible_id
  has_many :dashboard_tasks, -> { includes([:responsible, {:area => :hoshin}, :company])
    .merge(Task.unscoped.active)
    .merge(Hoshin.unscoped.active)
    .order(:deadline).references(:hoshin, :responsible, {area: :hoshin}, :task) }, :class_name => "Task", foreign_key: :responsible_id
  
  has_many :pending_tasks, -> { pending.includes([:responsible, {:area => :hoshin}, :company])
    .merge(Hoshin.unscoped.active)
    .order(:deadline).references(:hoshin, :responsible) }, :class_name => "Task", foreign_key: :responsible_id
  
  has_many :dashboard_indicators, -> { includes([:responsible, {:area => :hoshin}, :company])
    .merge(Hoshin.unscoped.active)
    .order(:next_update).references(:responsible, :hoshin) }, :class_name => "Indicator", foreign_key: :responsible_id
  
  has_many :pending_indicators, -> { pending.includes([:responsible, {:area => :hoshin}, :company])
    .merge(Hoshin.unscoped.active)
    .order(:next_update).references(:hoshin, :responsible) }, :class_name => "Indicator", foreign_key: :responsible_id
  
  
  has_many :companies, :through => :user_companies, :accessible => true
  has_many :user_companies, :dependent => :destroy 
  has_many :active_user_companies_and_hoshins, -> {includes(company: :active_hoshins)}, :class_name => "UserCompany", unscoped: true
  has_many :authorizations, :dependent => :destroy
  has_many :client_applications, :dependent => :destroy
  has_many :payments, :dependent => :destroy
  
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
  
  before_save do |user| 
    user.email_address.downcase!
    if user.color.nil? && !name.nil?
      user.color = hexFromString(name)
    end
  end
    
  def self.find_by_email_address(email)
    if email.kind_of?(Array)
      User.find_by email_address: email.map{ |s| s.downcase }
    else
      User.find_by email_address: email.downcase
    end
  end
  
  default_scope lambda { 
    where(:id => UserCompany.select(:user_id)
      .where('company_id=?',  
        Company.current_id) ) unless Company.current_id.nil? }    
       
  TODAY_SQL = "date_trunc('day',now() at time zone coalesce(users.timezone, 'Europe/Berlin'))"
  
  scope :at_hour, lambda { |*hour|
    where("date_part('hour',now() at time zone coalesce(users.timezone, 'Europe/Berlin')) = ?", hour) 
  }
  
  def next_tutorial
    ret = (User.values_for_tutorial_step - tutorial_step).first
    ret.nil? ? [] : ret 
  end
  
  def tutorial_complete?
    ret = next_tutorial.empty?
  end
  
  def available_logged_in
    acting_user unless acting_user.guest?
  end
  
  # --- Signup lifecycle --- #

  lifecycle do

    state :inactive, :default => true
    state :invited
    state :active
    
    create :from_omniauth, :params => [:name, :email_address], :become => :active do
      domain = self.email_address.split("@").last
      if (domain == "infojobs.net" || domain == "lectiva.com")
        self.companies = [Company.unscoped.find(1)]
      else
        Rails.logger.debug "------- Welcome email!"
        UserCompanyMailer.delay.welcome(self)
      end
    end

    create :invite, :new_key => true, :params => [:email_address], :become => :invited do
        self.email_address = email_address
        UserCompanyMailer.delay.new_invite(lifecycle.key, acting_user, self, acting_user.language.to_s)
    end
    
    transition :resend_invite, { :invited => :invited }, :new_key => true do
       UserCompanyMailer.delay.new_invite(lifecycle.key, acting_user, self, acting_user.language.to_s)
    end
      
    create :activate_ij,
        :params => [:name, :email_address, :password, :password_confirmation],
        :become => :active
    
    create :signup, :available_to => "Guest",
      :params => [:name, :email_address, :password, :password_confirmation],
      :become => :inactive, :new_key => true  do
      UserCompanyMailer.delay.activation(self, lifecycle.key)
    end
    
    transition :accept_invitation, { :invited => :active }, :available_to => :key_holder,
          :params => [:name, :password, :password_confirmation]

    transition :activate, { :inactive => :active }, :available_to => :key_holder do
      current_user = acting_user
      UserCompanyMailer.delay.welcome(self)
    end

    transition :activate, { :invited => :active } do
      acting_user = self
      @subject = "#{self.name} welcome to Hoshinplan!"
      UserCompanyMailer.delay.invited_welcome(self)
    end

    transition :request_password_reset, { :inactive => :inactive }, :new_key => true do
      UserCompanyMailer.delay.activation(self, lifecycle.key)
    end

    transition :request_password_reset, { :active => :active }, :new_key => true do
      UserCompanyMailer.delay.forgot_password(self, lifecycle.key)
    end

    transition :request_password_reset, { :invited => :invited }, :new_key => true do
      UserCompanyMailer.delay.forgot_password(self, lifecycle.key)
    end

    transition :reset_password, { :active => :active }, :available_to => :key_holder,
               :params => [ :password, :password_confirmation ]
               
    transition :reset_password, { :invited => :invited }, :available_to => :key_holder,
              :params => [ :password, :password_confirmation ]

  end
  
  def img_url(size) 
    key = "user-image-" + id.to_s + "-" + size.to_s
    ret = RequestStore.store[key]
    if ret.nil? 
      ret = image.url(size) if image.exists?
      RequestStore.store[key] = ret
    end
    ret
  end
  
  def abbrev
    name.split.map{|x| 
      x[0,1].upcase.tr('^A-Z','')
    }.join() unless name.nil?
  end
  
  def all_companies
    return @all_companies unless @all_companies.nil?
    @all_companies = active_user_companies_and_hoshins.map { |c|
      c.company
    }
  end
  
  def all_hoshins
    return @all_hoshins unless @all_hoshins.nil?
    @all_hoshins = []
    all_companies.each { |c|
      c.active_hoshins.each { |h|
        h.company_name = c.name
        @all_hoshins.push(h)        
      }
    }
    @all_hoshins
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
      User.current_user = ret
    end
    ret
  end
  
  def self.current_user=(id)
    RequestStore.store[:user] = id
  end
  
  # --- Permissions --- #

  def create_permitted?
    # Only the initial admin user can be created
    self.class.count == 0 || acting_user.administrator?
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
  
  def _same_company(cid=nil)
    return false unless self.signed_up?
    acting_user == self || acting_user.user_companies.where(:company_id => self.user_companies.*.company_id).present?
  end
  
  def _same_company_admin(cid=nil)
    return false unless self.signed_up?
    acting_user.user_companies.where(:state => :admin, :company_id => self.user_companies.*.company_id).present?
  end

  def view_permitted?(field)
    # permit password fields to avoid the reset password page to fail
    return true
    self.state == :invited ||
    field == :password || 
    field == :password_confirmation || 
    acting_user.administrator? || 
    self.new_record? || 
    self.guest? || 
    same_company
  end
  
  def name
    ret = firstName
    unless lastName.blank?
      ret += " " unless ret.blank? 
      ret += lastName
    end
    ret = ret.blank? ? super : ret
  end
  
  def update_data_from_authorization(provider, uid, email, firstName, lastName, remote_ip, tz, header_locale)
    authorization = Authorization.find_by_provider_and_uid(provider, uid)
    authorization ||= Authorization.find_by_email_address(email)
    atts = authorization.attributes.slice(*User.accessible_attributes.to_a)
    atts['image'].sub!('sz=50', 'sz=416') if atts['image']
    domain = authorization.email_address.split("@").last  
    atts.each { |k, v| 
      atts.delete(k) if !self.attributes[k].blank? || v.nil?
    }
    begin
      self.attributes = atts
    rescue
      self.attributes = atts.delete('photo')
    end
    self.firstName ||= firstName
    self.lastName ||= lastName
    if self.lifecycle.state.name == :invited
      self.lifecycle.activate!(self)
    end
    if self.timezone.nil? && !tz.nil?
   	  zone = tz
   	  zone = Hoshinplan::Timezone.get(zone)
      self.timezone = zone.name unless zone.nil?
    end
    if self.language.nil?
      self.language = header_locale || I18n.locale
    end
    begin
      self.save!
      people_set(self, remote_ip)
    rescue ActiveRecord::RecordInvalid => invalid
      fail ActiveRecord::RecordInvalid, invalid.record.errors.to_yaml if invalid.record && invalid.record.respond_to?('errors')
      fail ActiveRecord::RecordInvalid, invalid.record.to_yaml if invalid.record
      fail ActiveRecord::RecordInvalid, invalid.to_yaml
    end
  end
  
end
