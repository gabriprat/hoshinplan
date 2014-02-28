class Objective < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name        :string
    description :text
    indicators_count :integer, :default => 0, :null => false
    tasks_count :integer, :default => 0, :null => false
    timestamps
  end
  attr_accessible :name, :area, :area_id, :description, :responsible, :responsible_id, 
    :indicators, :tasks, :hoshin, :hoshin_id, :parent, :parent_id, :company, :company_id

  has_many :indicators, :dependent => :destroy, :inverse_of => :objective
  has_many :tasks, :dependent => :destroy, :inverse_of => :objective, :order => 'position'

  children :indicators, :tasks

  belongs_to :company

  belongs_to :parent, :class_name => "Objective"
  belongs_to :area, :inverse_of => :objectives, :counter_cache => false
  belongs_to :hoshin, :inverse_of => :objectives
  belongs_to :responsible, :class_name => "User", :inverse_of => :objectives
  
  acts_as_list :scope => :area
  
  validate :validate_company
  
  default_scope lambda { 
    where(:company_id => UserCompany.select(:company_id)
      .where('user_id=?',  
        User.current_id) ) }
  
  before_create do |objective|
      objective.company_id = objective.area.company_id
  end
  
  def area_objectives
    area.objectives
  end
  
  def company_users
    company.users
  end
  
  def parent_hoshin
    ret = hoshin.parent_id unless hoshin.nil?
    ret.nil? ? 0 : ret
  end

  def parent_objectives
    result = Objective.find_all_by_hoshin_id(parent_hoshin)
  end
  
  # --- Permissions --- #
  
  def same_company
    user = acting_user ? acting_user : User.find(User.current_id)
    cid = company_id ? company_id : Company.current_id
    ret = user.all_companies.where(:id => cid).exists?
    ret
  end
  
  def validate_company
    errors.add(:company, "You don't have permissions on this company") unless same_company
  end
  
  def create_permitted?
    same_company
  end

  def update_permitted?
    same_company
  end

  def destroy_permitted?
    same_company
  end

  def view_permitted?(field)
    same_company
  end

end
