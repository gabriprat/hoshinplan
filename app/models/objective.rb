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

  belongs_to :company, :inverse_of => :areas

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
    objective.company = objective.area.company
  end
  
  def parent_hoshin
    ret = area.hoshin.parent_id
    ret.nil? ? 0 : ret
  end

  def parent_objectives
    result = Objective.find_all_by_hoshin_id(parent_hoshin)
  end
  
  # --- Permissions --- #
  
  def same_company
    acting_user.user_companies.where(:company_id => self.company_id)
  end
  
  def validate_company
    errors.add(:company, "You don't have permissions on this company") unless same_company
  end
  
  def create_permitted?
    true
  end

  def update_permitted?
    same_company
  end

  def destroy_permitted?
    same_company
  end

  def view_permitted?(field)
    true
  end

end
