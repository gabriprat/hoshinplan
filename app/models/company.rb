class Company < ApplicationRecord

  acts_as_paranoid

  include ModelBase
  
  hobo_model # Don't put anything above this

  fields do
    name :string
    hoshins_count :integer, :default => 0, :null => false
    unlimited :boolean, :default => false, :null => false
    minimum_subscription_users :integer
    subscriptions_count :integer, :default => 0, :null => false
    payment_error :boolean
    credit :decimal, precision: 8, scale: 2, default: 0
    trial_ends_at   :date
    timestamps
    deleted_at :datetime
    charts_config :jsonb
  end
  index [:deleted_at]
  attr_accessible :id, :name, :creator, :creator_id, :unlimited, :company_email_domains, :trial_ends_at, :credit, :payment_error, :subscriptions_count, :minimum_subscription_users, :partner, :partner_id, :webhooks

  set_search_columns :name

  belongs_to :creator, :class_name => "User", :creator => true
  
  belongs_to :partner, :inverse_of => :companies

  has_many :company_email_domains, :accessible => true, :inverse_of => :company, :dependent => :destroy
  
  has_many :hoshins, -> { order :name }, :dependent => :destroy, :inverse_of => :company
  has_many :active_hoshins, -> { active.order :name }, :class_name => "Hoshin"
  
  has_many :areas, -> { order :name },:dependent => :destroy, :inverse_of => :company
  has_many :objectives, -> { order :name },:dependent => :destroy, :inverse_of => :company
  has_many :indicators, -> { order :name },:dependent => :destroy, :inverse_of => :company
  has_many :tasks, -> { order :name },:dependent => :destroy, :inverse_of => :company
  
  has_many :users, -> { where 'user_companies.roles_mask > 1' }, :through => :user_companies, :accessible => true
  has_many :user_companies, :dependent => :destroy
  
  has_many :subscriptions, :dependent => :destroy

  has_many :log, :class_name => "CompanyLog", :inverse_of => :company
  has_many :company_comments, :inverse_of => :company

  has_many :billing_details, :inverse_of => :company

  has_many :webhooks, :accessible => true, :inverse_of => :company, :dependent => :destroy
  
  children :hoshins
  
  after_create do |company|
    user = User.current_user
    user.tutorial_step << :company
    user.save!
    company.user_companies = [UserCompany::Lifecycle.new_company([company, user], {:user => user, :company => company})]
  end
  
  before_create do |company|
    cu = User.current_user
    domain = cu.email_address.split("@").last
    if domain == 'infojobs.net' || domain == 'scmspain.com' || domain == 'schibsted.com'
      self.unlimited = true
    end
  end

  before_create do |company|
    cu = User.current_user
    trial_days = cu.companies_trial_days
    if trial_days > 0
      self.trial_ends_at = Date.today + trial_days
    end
  end
  
  set_default_order :name
  
  default_scope lambda { 
    where("companies.id in (#{UserCompany.select(:company_id).where('user_id=?', User.current_id).to_sql})") unless User.current_id == -1 || (!User.current_user.nil? && User.current_user.respond_to?("administrator?") && User.current_user.administrator?) 
  }
  
  scope :admin, lambda { 
    where(:id => UserCompany.select(:company_id)
      .where('user_id=? and user_companies.state = ?',  
        User.current_id, :admin) ) }

  def default_charts_config
    [
        {'name' => 'value', 'visible' => true, 'lineColor' => '#008f55', 'dashArrays' => '', 'lineWidth' => 3, 'pointSize' => 3},
        {'name' => 'goal', 'visible' => true, 'lineColor' => '#b1c978', 'dashArrays' => '-', 'lineWidth' => 2, 'pointSize' => 0},
        {'name' => 'previous', 'visible' => true, 'lineColor' => '#ff7c00', 'dashArrays' => '', 'lineWidth' => 3, 'pointSize' => 0},
        {'name' => 'increment', 'visible' => true, 'lineColor' => '#999999', 'dashArrays' => '-', 'lineWidth' => 1, 'pointSize' => 3}
    ]
  end

  def charts_config
    self[:charts_config] || default_charts_config
  end

  def chart_props(prop)
    def get_prop(x, prop)
      if !x['visible'] && %w(lineWidth pointSize).include?(prop.to_s)
        0
      else
        x[prop.to_s]
      end
    end
    ret = charts_config.map{|x| get_prop(x, prop)}.join(',')
    ret
  end

  def toggle_chart_serie(idx)
    cc = charts_config
    cc[idx]['visible'] = !cc[idx]['visible']
    self.charts_config = cc
  end

  def collaborators=
  end
  
  def self.current_id=(id)
    RequestStore.store[:company_id] = id
  end

  def self.current_id
    RequestStore.store[:company_id]
  end  
  
  def self.current_company=(comp)
    RequestStore.store[:company] = comp
  end
  
  def self.current_company
    ret = RequestStore.store[:company]
    if (ret.nil? && !self.current_id.nil? && User.current_id)
      ret = Company.find(self.current_id)
      self.current_company = ret
    end
    ret
  end
  
  def comp_users
    ret = RequestStore.store[:comp_users]
    if (ret.nil? && !Company.current_id.nil?) 
      ret = {}
      users.each {|user|
        ret[user.id] = user
      }
      RequestStore.store[:comp_users] = ret
    end
    ret
  end
  
  def all_hoshins
    ret = RequestStore.store[:company_hoshins]
    if (ret.nil? && !Company.current_id.nil?) 
      ret = {}
      hoshins.each {|hoshin|
        ret[hoshin.id] = hoshin
      }
      RequestStore.store[:company_hoshins] = ret
    end
    ret
  end
  
  def collaborator_limits_reached?
    count = users.size
    return user_limit <= count
  end
  
  def user_limit
    users = 1
    if unlimited
      users = 1000000
    elsif subscriptions_count == 0 && creator.present? && trial_days_remaining > 0
      users = 200
    else
      subscriptions.where(status: 'Active').each { |subscription|
        if !users || users < subscription.users
          users = subscription.users
        end
      }
    end
    return users 
  end
  
  def flipper_id
    "Company:" + id.to_s
  end

  def trial_days_remaining
    if trial_ends_at.nil?
      ret = creator.nil? ? 0 :  creator.trial_days_remaining
    else
      ret = (trial_ends_at - Date.today).to_i
    end
    ret = 0 if ret < 0
    ret
  end

  def is_trial_expired?
    trial_days_remaining == 0
  end

  def enterprise?
    @enterprise ||= !is_trial_expired? || Subscription.where(company_id: id, status: 'Active', plan_name: 'Enterprise')
  end

  # --- Permissions --- #

  def create_permitted?
    User.current_user._?.signed_up?
  end

  def update_permitted?
     User.current_user.administrator? || same_company_admin(id)
  end

  def destroy_permitted?
     User.current_user.administrator? || same_company_admin(id)
  end
  
  
  def field_view_permitted?(field)
    case field
    when :company_email_domains
      #Only enterprise and unlimited users should be able to set automatic email domains
      enterprise? || unlimited
    when :webhooks
      #Only enterprise and unlimited users should be able to set webhooks
      enterprise? || unlimited
    else
      true
    end
  end
  
  def record_view_permitted?
    self.new_record? || User.current_user.administrator? || same_company(id)
  end
  
  def view_permitted?(field)    
   field_view_permitted?(field) && record_view_permitted?
  end

end
