class Area < ActiveRecord::Base

  include ModelBase

  hobo_model # Don't put anything above this
  
  include ColorHelper
  
  fields do
    name        :string, :null => false
    description :text
    color       Color
    timestamps
  end
  
  validates_presence_of :name

  attr_accessible :name, :description, :hoshin, :hoshin_id, :company, :company_id, :creator, :creator_id, :color
  
  belongs_to :creator, :class_name => "User", :creator => true
  
  has_many :objectives,  -> { order :obj_pos }, :dependent => :destroy, :inverse_of => :area
  has_many :indicators, -> { order :ind_pos }, :inverse_of => :area, :accessible => true
  has_many :tasks, -> { where(Task.visible.where_values).except(:order).reorder('CASE WHEN (status in (\'backlog\', \'active\')) THEN 0 ELSE 1 END, tsk_pos')}, :inverse_of => :area, :accessible => true

  belongs_to :hoshin, :inverse_of => :areas, :counter_cache => true, :null => false
  belongs_to :company, :inverse_of => :areas, :null => false
  
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
    #FIXME: Trying to avoid health not to appear on complete hoshinplans without goals 
    user.tutorial_step << :goal
    user.save!
  end
  
  after_update do |area|
    if area.hoshin_id_changed?
      Objective.update_all({:hoshin_id => hoshin_id}, {:area_id => id})
      Indicator.update_all({:hoshin_id => hoshin_id}, {:area_id => id})
      Task.update_all({:hoshin_id => hoshin_id}, {:area_id => id})
    end
  end
  
  def defaultColor
    str = "area+" + (name.nil? ? rand(1000000000).to_s(16) : name)
    res = hexFromString(str, 0.95 - (position.nil? ? 1 : position)/30.0)  
    return res
  end
  
  def child_tasks 
    child_hoshins = hoshin.children.*.id
    return nil unless child_hoshins
    child_objectives = Objective.where(:parent_id => objectives.*.id)
    tasks = Task
      .select("tasks.*, objectives.parent_id as parent_objective_id, objectives.hoshin_id")
      .joins(:objective).where(:objective_id => child_objectives, :show_on_parent => true)
      .where("status != 'deleted' and (status = 'active' or deadline>current_date-30)").reorder(:area_id, :tsk_pos)
    tasks.collect{ |t| t.becomes(ChildTask) }
  end
  
  def child_kpis
    child_hoshins = hoshin.children.*.id
    return nil unless child_hoshins
    child_objectives = Objective.where(:parent_id => objectives.*.id)
    indicators = Indicator
      .select("indicators.*, objectives.parent_id as parent_objective_id, objectives.hoshin_id")
      .joins(:objective).where(:objective_id => child_objectives, :show_on_parent => true).reorder(:area_id, :ind_pos)
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
    acting_user.administrator? || same_creator || hoshin_creator || same_company_admin
  end

  def view_permitted?(field)
    acting_user.administrator? || same_company
  end

end
