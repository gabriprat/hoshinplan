class Indicator < ApplicationRecord

  acts_as_paranoid

  include ModelBase
  
  hobo_model # Don't put anything above this

  fields do
    name        :string, :null => false
    value       :decimal
    description HoboFields::Types::TextilePlusString
    frequency   HoboFields::Types::EnumString.for(:weekly, :monthly, :quarterly)
    next_update :date
    last_update :date
    last_value  :decimal
    goal        :decimal, :default => 100.0
    worst_value :decimal, :default => 0.0
    reminder    :boolean, :default => true, :null => false
    show_on_parent  :boolean, :default => false, :null => false
    show_on_charts  :boolean, :default => true, :null => false
    timestamps
    deleted_at    :datetime
  end
  index [:deleted_at]
    
  validates_presence_of :name
  
  attr_accessible :name, :objective, :objective_id, :value, :description, :responsible, :responsible_id, :reminder,
   :frequency, :next_update, :goal, :worst_value, :area, :area_id, :trend, :company, :company_id, :show_on_parent,
   :creator_id, :last_update, :last_missing_value, :hoshin, :hoshin_id, :show_on_charts

  belongs_to :creator, :class_name => "User", :creator => true
  
  #Next line has a delete_all instead of destroy to prevent this object value 
  #from being updated just before being destroyed and creating errors
  has_many :indicator_histories, -> { order :day }, :dependent => :delete_all, :inverse_of => :indicator
  
  has_many :indicator_events, -> { order :day }, :dependent => :destroy, :inverse_of => :indicator
  
  has_many :log, :class_name => "IndicatorLog", :inverse_of => :indicator
  
  belongs_to :company, :null => false

  belongs_to :objective, :inverse_of => :indicators, :null => false
  belongs_to :hoshin, :inverse_of => :indicators, :counter_cache => false, :null => false, :unscoped => true, :touch => true
  
  belongs_to :area, :inverse_of => :indicators, :null => false
  belongs_to :responsible, :class_name => "User", :inverse_of => :indicators
  
  belongs_to :parent_objective, :inverse_of => :child_indicators, :class_name => 'Objective'
  belongs_to :parent_area, :inverse_of => :child_indicators, :class_name => 'Area'
  
  
  acts_as_list :scope => :area, :column => "ind_pos"
  
  validate :validate_company
  
  view_hints.parent  :hoshin
  
  set_default_order 'ind_pos'
  
  default_scope lambda { 
    if User.current_id && User.current_id != -1
      where(:company_id => UserCompany.select(:company_id)
        .where('user_id=?',  
          User.current_id) ).reorder('') 
    else
      reorder('')
    end
  }
  
  scope :order_hoshin, lambda {
    order('ind_pos')
  }
  
  scope :due, lambda { |*interval|
    joins(:responsible)
    .where("reminder = true 
      and next_update between #{User::TODAY_SQL}-interval ?  and #{User::TODAY_SQL}", interval)
  }
  
  scope :overdue, lambda {
    includes([:responsible, :area])
    .where("next_update < #{User::TODAY_SQL}").references(:responsible)
  }
  
  scope :under_tpc, lambda { |*tpc|
    where("goal<>worst_value and (100 * (value-worst_value) / (goal-worst_value)) < ?", tpc)
  }
  
  scope :pending, lambda { 
      where("next_update <= #{User::TODAY_SQL}")
      .reorder('indicators.next_update').references(:responsible)
  }
  
  scope :due_today, -> { due('0 hour') }
  
  after_destroy do |obj| 
    if obj.deleted_at.present? && obj.ind_pos.present?
      obj.ind_pos = nil
      obj.save!
    end
  end
  
  before_save do |indicator|
    if indicator.objective
      if indicator.show_on_parent && indicator.objective.parent
        indicator.parent_area_id = indicator.objective.parent.area_id
        indicator.parent_objective_id = indicator.objective.parent.id
      else
        indicator.parent_area_id = nil
        indicator.parent_objective_id = nil
      end
    end
  end
 
  before_create do |indicator|
    indicator.area = indicator.objective.area
    indicator.company = indicator.objective.company
    indicator.hoshin = indicator.objective.hoshin
  end
  
  after_create do |obj|
    user = User.current_user
    user.tutorial_step << :indicator
    user.save!
  end
  after_save :update_counter_cache
  after_destroy :update_counter_cache
  def update_counter_cache
    h = self.hoshin
    h.indicators_count = h.indicators.count
    h.save!
  end
  
  before_update do |indicator|
    #If we are changing the value we have to compute the date we are setting a value for
    indicator.compute_last_update!
    #Save the old value and compute next update date
    indicator.do_value_update!
    #Store value history
    indicator.update_history
  end
  
  def update_history
    unless self.last_update.nil?
      #only update trends once per day
      ih = IndicatorHistory.unscoped.where(:day => self.last_update, :indicator_id => self.id).first
      if ih.nil?
        ih = IndicatorHistory.create(:day => self.last_update, :indicator_id => self.id)
      end
      ih.value = self.value
      ih.goal ||= self.goal
      ih.save!
    end
  end
  
  def do_value_update!
    #This method only makes sense if the value and the update_date are changed
    return unless self.value_changed? && self.last_update_changed?
    self.last_value = self.value_was
    self.next_update = self.compute_next_update
  end
  
  def compute_last_update!
    return unless self.value_changed? #This method only makes sense if the value is changed
    return if self.last_update_changed? #If the user sets the value we should respect it    
    if self.next_update.nil?
      self.last_update = Date.today
    else
      self.last_update = self.next_update 
    end 
    self.last_update_will_change!
  end
  
  def destroyed_history!(ih)
    ind = self
    day = ind.next_update.nil? ? Date.today : ind.next_update
    latest = IndicatorHistory.latest(ind.id, ind.next_update, ih)
    if !ind.last_update.nil? && ind.last_update == ih.day
      update_from_history!(latest)
    end  
  end
  
  def update_from_latest_history!
    ind = self
    day = ind.next_update.nil? ? Date.today : ind.next_update
    lt = IndicatorHistory.latest(ind.id, ind.next_update)
    #Update the indicator value if we had no value or previous update or the next update is the same we have in the history
    if (lt.is_a?(IndicatorHistory) && (ind.value.nil? || ind.last_update.nil? || ind.next_update == lt.day))
      update_from_history!(lt)
    end
  end
  
  def update_from_history!(ih)
    return if ih.nil?
    ind = self
    ind.update_columns(last_value: ind.value) unless ind.value == ih.value
    ind.update_columns(value: ih.value) unless ind.value == ih.value
    ind.update_columns(goal: ih.goal) unless ih.goal.nil? || ind.goal == ih.goal
    unless ind.last_update == ih.day 
      ind.update_columns(last_update: ih.day) 
      ind.update_columns(next_update: ind.compute_next_update)
    end
    ind.value_will_change!
    ind.touch
  end
  
  def status 
    if !next_update.nil?
      if next_update > Date.today
        :current
      elsif next_update == Date.today
        :due
      elsif next_update < Date.today && next_update > (Date.today - increment(frequency))
        :overdue
      else
        :multioverdue
      end
    end
  end 
  
  def trend
    if last_value.nil? || value.nil?
      :equal
    else 
      if last_value == value 
        :equal 
      else 
        ((last_value < value && higher?) || (value < last_value && !higher?)) ? :positive : :negative
      end
    end
  end
    
  def higher?
    goal.nil? || worst_value.nil? ? true : worst_value < goal
  end
  
  def tpc 
    ret = 0
    return ret if goal.nil?
    if !worst_value.nil? && !value.nil? && (goal-worst_value)!=0
      ret = 100 * (value-worst_value) / (goal-worst_value)
    end 
  end
  
  def last_missing_value
    return nil if next_update.nil?
    n = next_update + increment(frequency)
    p = next_update
    while (n <= Date.today)
      n += increment(frequency)
      p += increment(frequency)
    end
    p
  end
  
  def compute_next_update
    return nil if last_update.nil?
    return self.next_update if next_update.present? && self.last_update_changed? && last_update < next_update #If overwriting or setting a value before the next update date
    next_update_after(self.last_update, self.frequency)
  end
  
  def next_update_after(d, freq)
    return nil if d.nil?
    d + increment(freq)
  end
  
  def increment(freq)
    valid = validate_frequency(freq)
    raise ArgumentError.new(valid) unless valid.nil?
    case freq.to_s
    when "weekly"
      1.week
    when "monthly"
      1.month
    when "quarterly"
      3.month
    else
      #That should never happen since we validated it above
      raise ArgumentError.new("Unexpected frequency")
    end
  end
  
  def validate_frequency(freq)
    klass = Indicator.attr_type :frequency
    klass.new(freq).validate
  end
  
  # --- Permissions --- #
  
  def validate_company
    errors.add(:company, "You don't have permissions on this company") unless same_company
  end
  
  def create_permitted?
    acting_user.administrator? || same_company_editor
  end

  def update_permitted?
    acting_user.administrator? || same_company_editor
  end

  def destroy_permitted?
    acting_user.administrator? || same_company_admin || same_creator || hoshin_creator
  end

  def view_permitted?(field=nil)
    acting_user.administrator? || same_company
  end
  
end

class ChildIndicator < Indicator
end