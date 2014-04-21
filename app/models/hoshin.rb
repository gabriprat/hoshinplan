class Hoshin < ActiveRecord::Base
  
  include ModelBase

  hobo_model # Don't put anything above this

  fields do
    name :string
    goals_count :integer, :default => 0, :null => false
    areas_count :integer, :default => 0, :null => false
    objectives_count :integer, :default => 0, :null => false
    indicators_count :integer, :default => 0, :null => false
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
  }
  
  after_create do |obj|
    user = User.current_user
    user.tutorial_step << :hoshin
    user.save!
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
  
  def health
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
    same_company
  end

  def destroy_permitted?
    same_company_admin
  end

  def view_permitted?(field)
    self.new_record? || same_company
  end

end
