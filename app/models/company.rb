class Company < ActiveRecord::Base

  hobo_model # Don't put anything above this
  
  fields do
    name :string
    hoshins_count :integer, :default => 0, :null => false
    timestamps
  end
  attr_accessible :name
  
  has_many :hoshins, :dependent => :destroy, :inverse_of => :company, :order => :name
  has_many :areas, :dependent => :destroy, :inverse_of => :company, :order => :name
  has_many :objectives, :dependent => :destroy, :inverse_of => :company, :order => :name
  has_many :indicators, :dependent => :destroy, :inverse_of => :company, :order => :name
  has_many :tasks, :dependent => :destroy, :inverse_of => :company, :order => :name
  
  has_many :users, :through => :user_companies, :accessible => true
  has_many :user_companies, :dependent => :destroy
  
  children :hoshins
  
  after_create do |company|
    user = acting_user
    company.user_companies = [UserCompany::Lifecycle.new_company([company, user], {:user => user, :company => company})]
  end

  default_scope lambda { 
    where(:id => UserCompany.select(:company_id)
      .where('user_id=?',  
        User.current_id) ) }
  
  scope :admin, lambda { 
    where(:id => UserCompany.select(:company_id)
      .where('user_id=? and user_companies.state = ?',  
        User.current_id, :admin) ) }
        
  def self.current_id=(id)
    Thread.current[:company_id] = id
  end

  def self.current_id
    Thread.current[:company_id]
  end  

  # --- Permissions --- #

  def create_permitted?
    users(acting_user)
  end

  def update_permitted?
    acting_user.administrator? || acting_user.respond_to?("id") && !user_companies.user_is(acting_user.id).administrator.empty?
  end

  def destroy_permitted?
    acting_user.administrator? || acting_user.respond_to?("id") && !user_companies.user_is(acting_user.id).administrator.empty?
  end

  def view_permitted?(field)
    acting_user.administrator? || acting_user.respond_to?("id") && !user_companies.user_is(acting_user.id).empty?
  end

end
