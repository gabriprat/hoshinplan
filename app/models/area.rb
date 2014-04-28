class Area < ActiveRecord::Base

  include ModelBase

  hobo_model # Don't put anything above this
  
  include ColorHelper
  
  fields do
    name        :string, :null => false
    description :text
    color       Color
    objectives_count :integer, :default => 0, :null => false
    indicators_count :integer, :default => 0, :null => false
    tasks_count :integer, :default => 0, :null => false
    timestamps
  end

  attr_accessible :name, :description, :hoshin, :hoshin_id, :company, :company_id, :creator_id, :color
  
  belongs_to :creator, :class_name => "User", :creator => true
  never_show :creator
  
  has_many :objectives, :dependent => :destroy, :inverse_of => :area, :order => 'obj_pos'
  has_many :indicators, :through => :objectives, :accessible => true, :order => 'ind_pos'
  has_many :tasks, :through => :objectives, :accessible => true, :order => 'status, tsk_pos', :conditions => Task.visible.where_values

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
  
  before_save do |area|
    area.color = area.defaultColor if area.color.blank?
  end
  
  after_create do |obj|
    user = User.current_user
    user.tutorial_step << :area
    user.save!
  end
  
  def defaultColor
    str = name.nil? ? 'area-' : name + "+"
    str += id.nil? ? rand(1000000000).to_s(16) : id.to_s
    res = hexFromString(str, 0.95 - (position.nil? ? 1 : position)/30.0)  
    return res
  end
  
  def color
    if super().blank? 
      self.color = self.defaultColor
    end 
    super()
  end
  
  def child_tasks 
    child_hoshins = hoshin.children.*.id
    return nil unless child_hoshins
    child_objectives = Objective.where(:parent_id => objectives.*.id)
    tasks = Task
      .select("tasks.*, objectives.parent_id as parent_objective_id, objectives.hoshin_id")
      .joins(:objective).where(:objective_id => child_objectives, :show_on_parent => true)
      .where("status != 'deleted' and (status = 'active' or deadline>current_date-30)")
    tasks.collect{ |t| t.becomes(ChildTask) }
  end
  
  def child_kpis
    child_hoshins = hoshin.children.*.id
    return nil unless child_hoshins
    child_objectives = Objective.where(:parent_id => objectives.*.id)
    indicators = Indicator
      .select("indicators.*, objectives.parent_id as parent_objective_id, objectives.hoshin_id")
      .joins(:objective).where(:objective_id => child_objectives, :show_on_parent => true)
    indicators.collect{ |t| t.becomes(ChildIndicator) }
  end
  
  def parent_hoshin
    ret = hoshin.parent_id
    ret.nil? ? 0 : ret
  end

  def parent_objectives
    result = Objective.find_all_by_hoshin_id(parent_hoshin)
  end
  
  # --- Permissions --- #
  def validate_company
    errors.add(:company, "You don't have permissions on this company") unless same_company
  end
  
  def create_permitted?
    acting_user.administrator? || same_company
  end

  def update_permitted?
    acting_user.administrator? || same_company
  end

  def destroy_permitted?
    acting_user.administrator? || same_company_admin
  end

  def view_permitted?(field)
    acting_user.administrator? || same_company
  end

end
