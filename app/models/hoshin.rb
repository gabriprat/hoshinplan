class Hoshin < ActiveRecord::Base
  
  include ModelBase

  hobo_model # Don't put anything above this

  fields do
    name :string
    goals_count :integer, :default => 0, :null => false
    areas_count :integer, :default => 0, :null => false
    objectives_count :integer, :default => 0, :null => false
    indicators_count :integer, :default => 0, :null => false
    outdated_indicators_count :integer, :default => 0, :null => false
    outdated_tasks_count :integer, :default => 0, :null => false
    blind_objectives_count :integer, :default => 0, :null => false
    neglected_objectives_count :integer, :default => 0, :null => false
    tasks_count :integer, :default => 0, :null => false
    objectives_count :integer, :default => 0, :null => false
    header HoboFields::Types::TextileString
    timestamps
  end
  attr_accessible :name, :id, :parent, :parent_id, :company, :company_id, :header
  attr_accessible :areas, :children, :children_ids, :creator_id
  
  belongs_to :creator, :class_name => "User", :creator => true
  never_show :creator

  belongs_to :company, :inverse_of => :hoshins, :counter_cache => true
  belongs_to :parent, :class_name => "Hoshin"
  has_many :children, :class_name => "Hoshin", :foreign_key => "parent_id", :dependent => :destroy
  
  has_many :areas, :dependent => :destroy, :inverse_of => :hoshin, :order => :position
  has_many :objectives, :through => :areas, :inverse_of => :hoshin, :accessible => true
  has_many :indicators, :through => :objectives, :inverse_of => :hoshin, :accessible => true
  has_many :tasks, :through => :objectives, :accessible => true
  has_many :goals, :dependent => :destroy, :inverse_of => :hoshin, :order => :position
  
  children :areas
  
  validate :validate_company
  
  default_scope lambda { 
    where(
        :company_id => (Company.current_id ? Company.current_id : User.current_id.nil? ? -1 : User.find(User.current_id).companies)
    )
  };
  
  after_create do |obj|
    user = User.current_user
    user.tutorial_step << :hoshin
    user.save!
  end
  
  def taks_by_status(status)
    tasks.where(:status => status)
  end
  
  def backlog_tasks
    tasks.backlog.order(:lane_pos)
  end
  def active_tasks
    tasks.active.order(:lane_pos)
  end
  def completed_tasks
    tasks.completed.order(:lane_pos)
  end
  def discarded_tasks
    tasks.discarded.order(:lane_pos)
  end
  
  def health_update!
    neglected = objectives.neglected.count(:id)
    self.neglected_objectives_count = neglected
    
    outdated_ind = indicators.overdue.count(:id)
    self.outdated_indicators_count = outdated_ind

    outdated_tsk = tasks.overdue.count(:id)
    self.outdated_tasks_count = outdated_tsk
    
    blind = objectives.blind.count(:id)
    self.blind_objectives_count = blind  

    self.save!
  end
  
  def users_with_pending_actions
    users = {}
    (objectives.neglected | objectives.blind | indicators.overdue | tasks.overdue).each {|o|
      if (users.has_key? o.responsible)
        users[o.responsible] += 1
      else
        users[o.responsible]=1
      end
    }
    users.sort_by {|k,v| v}.reverse
  end
  
  def cache_key
    objids = Objective.select("id").where(:hoshin_id => id).*.id
    kpiids = Indicator.select("id").includes(:area).where("areas.hoshin_id = ?", id).*.id
    tskids = Task.select("id").includes(:area).where("areas.hoshin_id = ?", id).*.id
    objids = objids.map { |id| "o" + id.to_s }
    kpiids = kpiids.map { |id| "k" + id.to_s }
    tskids = tskids.map { |id| "t" + id.to_s }
    (objids + kpiids + tskids).join("-").hash
  end
  
  def objectives_health
    100.0 * (1.0 - (neglected_objectives_count.to_f + blind_objectives_count.to_f ) / objectives_count.to_f)
  end
  
  def indicators_health
    100.0 * (1.0 - outdated_indicators_count.to_f / indicators_count.to_f)
  end
  
  def tasks_health
    100.0 * (1.0 - outdated_tasks_count.to_f / tasks_count.to_f)
  end
  
  def health
    ret = incomplete_health
    return ret unless ret[:action] == "none"
    
    obj = objectives_health
    ind = indicators_health
    tsk = tasks_health
  
    ret = {:value => (obj+ind+tsk)/3, :action => "none"}
  end
  
  def incomplete_health
    value = 20
    if goals.size == 0
       ret = {:action => "goal"}
    else
      value += 16
    end
    if areas.size == 0
       ret = ret || {:action => "area"}
    else
       value += 16
    end
    if objectives.size == 0
      ret = ret || { :action => "objective"}
    else
      value += 16
    end
    if indicators.size == 0
      ret = ret || { :action => "indicator"}
    else
      value += 16
    end
    if tasks.size == 0
      ret = ret || { :value => 75, :action => "task"}
    else
      value += 16
    end
    if !User.current_user.tutorial_step?(:followup)
      ret = ret || {:action => "followup"}
    end
    ret = ret || {:action => "none"}
    ret[:value] = value
    return ret
  end
  
  def tutorial
    if User.current_user == creator && !User.current_user.tutorial_step?(:followup) && health[:action] != 'none' 
       "tutorial"
    else 
      ""
    end
  end
  
  # --- Permissions --- #
  
  def parent_same_company
    parent_id.nil? || Hoshin.find(parent_id).company_id == company_id
  end
  
  def validate_company
    errors.add(:company, I18n.t("errors.permission_denied", :default => "Permission denied")) unless same_company
    errors.add(:parent, I18n.t("errors.parent_hoshin_same_company", :default => "Parent hoshin must be from the same company")) unless parent_same_company
  end

  def create_permitted?
    true
  end

  def update_permitted?
    acting_user.administrator? || same_company
  end

  def destroy_permitted?
    acting_user.administrator? || same_company_admin
  end

  def view_permitted?(field)
    acting_user.administrator? || self.new_record? || same_company
  end

end
