class Area < ActiveRecord::Base

  hobo_model # Don't put anything above this
  
  fields do
    name        :string
    description :text
    timestamps
  end

  attr_accessible :name, :description, :hoshin, :hoshin_id, :company, :company_id

  has_many :objectives, :dependent => :destroy, :inverse_of => :area, :order => 'position'
  has_many :indicators, :through => :objectives, :accessible => true, :order => 'position'
  has_many :tasks, :through => :objectives, :accessible => true, :order => 'position'

  belongs_to :hoshin, :inverse_of => :areas, :counter_cache => true
  belongs_to :company, :inverse_of => :areas
  
  acts_as_list :scope => :hoshin
  
  validate :validate_company
  
  default_scope lambda { 
    where(:company_id => UserCompany.select(:company_id)
      .where('user_id=?',  
        User.current_id) ) }
        
  before_create do |area|
    area.company = area.hoshin.company
  end
  
  def child_tasks 
    child_hoshins = hoshin.children.*.id
    return nil unless child_hoshins
    child_objectives = Objective.where(:parent_id => objectives.*.id)
    tasks = Task.where(:objective_id => child_objectives, :show_on_parent => true)
    tasks.collect{ |t| t.becomes(ChildTask) }
  end
  
  def parent_hoshin
    ret = hoshin.parent_id
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
