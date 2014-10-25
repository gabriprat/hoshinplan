class Objective < ActiveRecord::Base

  include ModelBase
  
  
  hobo_model # Don't put anything above this

  fields do
    name        :string
    description HoboFields::Types::TextileString
    indicators_count :integer, :default => 0, :null => false
    tasks_count :integer, :default => 0, :null => false
    timestamps
  end
  attr_accessible :name, :area, :area_id, :description, :responsible, :responsible_id, 
    :indicators, :tasks, :hoshin, :hoshin_id, :parent, :parent_id, :company, :company_id, :creator_id
    
  belongs_to :creator, :class_name => "User", :creator => true  

  has_many :indicators, :dependent => :destroy, :inverse_of => :objective
  has_many :tasks, -> { order :tsk_pos }, :dependent => :destroy, :inverse_of => :objective

  children :indicators, :tasks

  belongs_to :company

  belongs_to :parent, :class_name => "Objective"
  belongs_to :area, :inverse_of => :objectives, :counter_cache => true
  belongs_to :hoshin, :inverse_of => :objectives, :counter_cache => true
  belongs_to :responsible, :class_name => "User", :inverse_of => :objectives
  
  acts_as_list :scope => :area, :column => "obj_pos"
  
  validate :validate_company
  
  default_scope lambda { 
    where(:company_id => UserCompany.select(:company_id)
      .where('user_id=?',  
        User.current_id)
      ).reorder('obj_pos')
  }
        
  scope :blind, -> {
    indicator = Indicator.arel_table
    objective = Objective.arel_table
    indicator_cond = includes([:area, :responsible])
    .where(Indicator.unscoped
        .where(indicator[:objective_id].eq(objective[:id]))
        .exists.not).references(:responsible)
  }
  
  scope :neglected, -> { 
    task = Task.arel_table
    objective = Objective.arel_table
    tasks_cond = task[:objective_id].eq(objective[:id]).and(task[:status].eq(:active))
    indicator = Indicator.arel_table
    ind_cond = indicator[:objective_id].eq(objective[:id])
    includes([:area, :responsible])
    .where(Task.unscoped.where(tasks_cond).exists.not)
      .where(Indicator.unscoped.under_tpc(100).where(ind_cond).exists).references(:responsible)
  }
  
  after_save "hoshin.health_update!"
  after_destroy "hoshin.health_update!"
        
  before_create do |objective|
      objective.company_id = objective.area.company_id
  end
  
  before_create do |obj|
    user = User.current_user
    user.tutorial_step << :objective
    user.save!
  end
  
  after_update do |obj|
    if obj.area_id_changed?
      obj.indicators.update_all(:area_id => area_id) unless obj.indicators.blank?
      obj.tasks.update_all(:area_id => area_id) unless obj.tasks.blank?
    end
  end
  
  def position
    obj_pos
  end
  
  def area_objectives
    area.objectives
  end
  
  def company_users
    company.users
  end
  
  def parent_hoshin
    ret = hoshin.parent_id unless hoshin.nil?
    ret.nil? ? -1 : ret
  end

  def parent_objectives
    if parent_hoshin.nil? || parent_hoshin < 1 
      result = []
    else
      result = Objective.find_all_by_hoshin_id(parent_hoshin) unless parent_hoshin < 1
    end
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
