class Hoshin < ActiveRecord::Base
  
  acts_as_paranoid
  
  include ModelBase
  include ColorHelper

  hobo_model # Don't put anything above this

  fields do
    name :string, :default => 'plan', :null => false
    goals_count :integer, :default => 0, :null => false
    areas_count :integer, :default => 0, :null => false
    objectives_count :integer, :default => 0, :null => false
    indicators_count :integer, :default => 0, :null => false
    outdated_indicators_count :integer, :default => 0, :null => false
    outdated_tasks_count :integer, :default => 0, :null => false
    blind_objectives_count :integer, :default => 0, :null => false
    neglected_objectives_count :integer, :default => 0, :null => false
    tasks_count :integer, :default => 0, :null => false
    hoshins_count :integer, :default => 0, :null => false
    header HoboFields::Types::TextileString
    health_updated_at :datetime
    color       Color 
    timestamps
    deleted_at    :datetime
    ancestry      :string
  end
  index [:deleted_at]
  
  has_attached_file :image, {
    :styles => {
      :blur => "104x104#",
      :thumb2x => "208x208#",
      :thumb => "104x104#",
      :mini2x => "58x58#",
      :mini => "29x29#"
    },
    :convert_options => {
      :blur => "-blur 0x12 -fill black -colorize 20% -quality 80 -interlace Plane",
      :mini => "-quality 80 -interlace Plane",
      :mini2x => "-quality 80 -interlace Plane",
      :thumb => "-quality 80 -interlace Plane",
      :thumb2x => "-quality 80 -interlace Plane"
    },
    :s3_headers => { 
      'Cache-Control' => 'public, max-age=315576000', 
      'Expires' => 10.years.from_now.httpdate 
    },
    :default_url => "/assets/default.jpg"
  }
  crop_attached_file :image
  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/
  validates_attachment_size :image, :less_than => 10.megabytes   
    
  attr_accessible :name, :id, :parent, :parent_id, :company, :company_id, :header, :areas, :creator_id, :creator, :color, :image
    
  has_ancestry 
  
  belongs_to :creator, :class_name => "User", :creator => true, :inverse_of => :my_hoshins

  belongs_to :company, :inverse_of => :hoshins, :counter_cache => true
  
  has_many :areas, -> { order :position }, :dependent => :destroy, :inverse_of => :hoshin
  has_many :objectives, -> { readonly }, :through => :areas, :inverse_of => :hoshin, :accessible => true
  has_many :indicators, -> { readonly }, :through => :objectives, :inverse_of => :hoshin, :accessible => true
  has_many :tasks, -> { readonly }, :through => :objectives, :accessible => true
  has_many :goals, -> { order :position }, :dependent => :destroy, :inverse_of => :hoshin
  has_many :log, :class_name => "HoshinLog", :inverse_of => :hoshin
  
  children :areas
  
  validate :validate_company
  validate :validate_different_parent
  
  amoeba do
    enable
    include_association :areas
    include_association :goals
    nullify :image_file_name
    nullify :image_content_type
    nullify :image_file_size
    nullify :image_updated_at
    customize(lambda { |original, clone|
      clone.name = I18n.t('copy_of', default: 'Copy of') + " " + clone.name
    })
  end
  
  before_save do |hoshin|
    hoshin.color = hoshin.defaultColor if hoshin.color.blank?
  end
  
  def defaultColor
    str = "hoshin+" + (name.nil? ? rand(1000000000).to_s(16) : name)
    res = hexFromString(str, 0.95)  
    return res
  end

  lifecycle do

    state :active, :default => true
    state :archived
    
    create :create, :become => :active
    transition :activate, { :archived => :active }, :available_to => :transition_available
    transition :archive, { :active => :archived }, :available_to => :transition_available
    transition :clone, {:active => :active}, :available_to => :clone_available do 
      b = self.amoeba_dup 
      b.save!
      Hoshin.reset_counters b.id, :areas, :goals
    end
    transition :clone, {:archived => :archived}, :available_to => :clone_available do self.amoeba_dup.save! end
  end  
  
  def transition_available
    return acting_user if same_creator || same_company_admin
  end
  
  def clone_available
    return acting_user if same_company
  end
  
  default_scope lambda {
    if Company.current_id
      where(:company_id => Company.current_id)
    elsif User.current_id != -1
      where(:company_id => UserCompany.select(:company_id).where(:user_id => User.current_id)) unless User.current_user == -1
    end
  }
  
  after_create do |obj|
    user = User.current_user
    user.tutorial_step << :hoshin
    user.save!
  end
  
  def company_name=(name)
    @company_name = name
  end
  
  def company_name
    @company_name
  end
  
  def taks_by_status(status)
    tasks.where(:status => status)
  end
  
  def backlog_tasks
    tasks.backlog.reorder(:lane_pos)
  end
  def active_tasks
    tasks.active.reorder(:lane_pos)
  end
  def completed_tasks
    tasks.completed.visible.reorder(:lane_pos)
  end
  def discarded_tasks
    tasks.discarded.visible.reorder(:lane_pos)
  end
  def outdated_tasks
    tasks.overdue
  end
  def outdated_indicators
    tasks.overdue
  end
  def blind_indicators
    tasks.overdue
  end
  def outdated_indicators
    tasks.overdue
  end
  
  def needs_health_update?
    # I assume that health computed within one second is updated
    self.health_updated_at.nil? || self.updated_at.nil? || self.updated_at - self.health_updated_at > 1
  end
  
  def sync_health_update!(force = false)
    Rails.logger.debug "==== Health update!"
    if self.readonly?
      logger.debug "====== Not updating read-only hoshin"
      return
    end
    
    unless force || needs_health_update?
      logger.debug "====== END: Health update! Not updating an already updated hoshin"
      return      
    end
    Objective.transaction do
      objectives = Objective.unscoped.where(hoshin_id: id, deleted_at: nil)
      objectives.update_all({neglected: false, blind: false})
      neglected = objectives.neglected
      neglected.update_all(neglected: true)
      self.neglected_objectives_count = neglected.count(:id)
  
      outdated_ind = Indicator.unscoped.where(hoshin_id: id, deleted_at: nil).overdue.count(:id)
      self.outdated_indicators_count = outdated_ind

      outdated_tsk = Task.unscoped.where(hoshin_id: id, deleted_at: nil).overdue.count(:id)
      self.outdated_tasks_count = outdated_tsk
  
      blind = Objective.unscoped.where(hoshin_id: id, deleted_at: nil).blind
      blind.where(blind: false).update_all(blind: true)
      self.blind_objectives_count = blind.count(:id)

      self.touch(:health_updated_at)
      self.save!
    end
    Rails.logger.debug "==== END: Health update!"
  end
  
  after_update do |hoshin|
    if hoshin.company_id_changed?
      IndicatorHistory.joins(:indicator).where(:indicators => {:hoshin_id => id}).update_all(:company_id => company_id)
      Indicator.where(:hoshin_id => id).update_all({:company_id => company_id})
      Task.where(:hoshin_id => id).update_all({:company_id => company_id})
      Objective.where(:hoshin_id => id).update_all({:company_id => company_id})
      Area.where(:hoshin_id => id).update_all({:company_id => company_id})
      Goal.where(:hoshin_id => id).update_all({:company_id => company_id})
    end
    #if needs_health_update?
    #  Jobs::HealthUpdate.delay.perform id
    #end
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
    return 100.0 if objectives_count.to_f == 0
    return 0 if neglected_objectives_count.to_f + blind_objectives_count.to_f > objectives_count.to_f
    100.0 * (1.0 - (neglected_objectives_count.to_f + blind_objectives_count.to_f ) / objectives_count.to_f)
  end
  
  def indicators_health
    return 100.0 if indicators_count.to_f == 0
    100.0 * (1.0 - outdated_indicators_count.to_f / indicators_count.to_f)
  end
  
  def tasks_health
    return 100.0 if tasks_count.to_f == 0
    100.0 * (1.0 - outdated_tasks_count.to_f / tasks_count.to_f)
  end
  
  def health
    ret = incomplete_health
    #return ret if ret[:value] < 100 && ret[:action] != 'none'
    
    if needs_health_update?
      sync_health_update!
    end
    
    obj = objectives_health
    ind = indicators_health
    tsk = tasks_health

    ret[:value] = (obj+ind+tsk)/3
    ret
  end
  
  def incomplete_health
    value = 20
    ret = {:action => "none"} unless creator_id == User.current_id
    if goals.size == 0
       ret = ret || {:action => "goal"}
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
    if ret[:action] == "goal" && ret[:value] > 80
      ret[:action] = "none"
      ret[:value] = 100
    end
    return ret
  end
  
  def tutorial
    if User.current_user.id == creator_id && !User.current_user.tutorial_step?(:followup) && health[:action] != 'none' 
       "tutorial"
    else 
      ""
    end
  end
  
  # --- Permissions --- #
  
  # We need this method because update_permitted? is dependant on the value
  # of company so it would be marked as not editable
  def company_edit_permitted?
    acting_user.administrator? || same_company
  end
  
  def parent_same_company
    User.current_user._?.administrator? || parent_id.nil? || Hoshin.unscoped.find(parent_id).company_id == company_id
  end
  
  def validate_company
    errors.add(:company, I18n.t("errors.permission_denied", :default => "Permission denied")) unless same_company
    errors.add(:parent, I18n.t("errors.parent_hoshin_same_company", :default => "Parent hoshin must be from the same company")) unless parent_same_company
  end
  
  def validate_different_parent
    errors.add(:parent, I18n.t("errors.different_parent")) unless parent_id.nil? || parent_id != id
  end
  
  def create_permitted?
    true
  end

  def update_permitted?
    acting_user.administrator? || same_company
  end

  def destroy_permitted?
    acting_user.administrator? || same_creator || same_company_admin
  end

  def view_permitted?(field)
    acting_user.administrator? || self.new_record? || same_company
  end

end
