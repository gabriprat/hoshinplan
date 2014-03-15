class Company < ActiveRecord::Base

  include ModelBase
  
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
          
  def collaborators=
  end
  
  def self.current_id=(id)
    RequestStore.store[:company_id] = id
  end

  def self.current_id
    RequestStore.store[:company_id]
  end  
  
  def self.current_company
    ret = RequestStore.store[:company]
    if (ret.nil? && !self.current_id.nil?) 
      ret = Company.find(self.current_id)
      RequestStore.store[:company] = ret
    end
    ret
  end
  
  def user_abbrevs
    ret = RequestStore.store[:user_abbrevs]
    if (ret.nil? && !Company.current_id.nil?) 
      ret = {}
      users.each {|user|
        ret[user.id] = user.name
      }
    end
    ret
  end

  # --- Permissions --- #

  def create_permitted?
    acting_user.signed_up?
  end

  def update_permitted?
     acting_user.administrator? || same_company_admin(id)
  end

  def destroy_permitted?
     acting_user.administrator? || same_company_admin(id)
  end

  def view_permitted?(field)
    new_record? || acting_user.administrator? || same_company(id)
  end

end
