class Indicator < ActiveRecord::Base

  include ModelBase
  
  hobo_model # Don't put anything above this

  fields do
    name        :string, :null => false
    value       :decimal
    description HoboFields::Types::TextileString
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
  end
  
  validates_presence_of :objective, :name
  
  attr_accessible :name, :objective, :objective_id, :value, :description, :responsible, :responsible_id, :reminder,
   :frequency, :next_update, :goal, :worst_value, :area, :area_id, :trend, :company, :company_id, :show_on_parent,
   :creator_id, :last_update, :last_missing_value, :hoshin, :hoshin_id, :show_on_charts

  belongs_to :creator, :class_name => "User", :creator => true
  
  has_many :indicator_histories, -> { order :day }, :dependent => :destroy, :inverse_of => :indicator
  
  belongs_to :company, :null => false

  belongs_to :objective, :inverse_of => :indicators, :null => false
  belongs_to :hoshin, :inverse_of => :indicators, :counter_cache => true, :null => false, :touch => true
  
  belongs_to :area, :inverse_of => :indicators, :null => false
  belongs_to :responsible, :class_name => "User", :inverse_of => :indicators
  
  belongs_to :parent_objective, :inverse_of => :child_indicators, :class_name => 'Objective'
  belongs_to :parent_area, :inverse_of => :child_indicators, :class_name => 'Area'
  
  
  acts_as_list :scope => :area, :column => "ind_pos"
  
  validate :validate_company
  
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
  
  before_save do |indicator|
    return unless indicator.objective
    if indicator.show_on_parent && indicator.objective.parent_id
      indicator.parent_area_id = indicator.objective.parent.area_id
      indicator.parent_objective_id = indicator.objective.parent_id
    else
      indicator.parent_area_id = nil
      indicator.parent_objective_id = nil
    end
  end
 
  before_create do |indicator|
    indicator.company = indicator.objective.company
    indicator.hoshin = indicator.objective.hoshin
  end
  
  after_create do |obj|
    user = User.current_user
    user.tutorial_step << :indicator
    user.save!
  end
  
  after_destroy 'hoshin.touch'
  
  before_update do |indicator|
    if (!indicator.value.nil? && indicator.value_changed? && !indicator.last_update_changed? && (indicator.next_update.nil? || indicator.next_update <= Date.today))
        if indicator.next_update.nil?
          indicator.last_update = Date.today
        else
          indicator.last_update = indicator.next_update 
        end 
        indicator.last_update_will_change!
    end
    if indicator.value_changed? && indicator.last_update_changed?
      if indicator.last_update.nil? || indicator.last_update_changed?
        #only update trends once per day
        indicator.last_value = indicator.value_was
        indicator.next_update = compute_next_update(indicator)
      end
    end
    update_date = indicator.last_update
    unless update_date.nil?
      ih = IndicatorHistory.unscoped.where(:day => update_date, :indicator_id => indicator.id).first
      if ih.nil?
        ih = IndicatorHistory.create(:day => update_date, :indicator_id => indicator.id, :goal => indicator.goal)
      end
      ih.value = indicator.value
      ih.goal = indicator.goal
      ih.save!
    end
  end
  
  def update_from_history!(destroy=false, ih=nil)
    ind = self
    latest = IndicatorHistory.where("indicator_id = ? and day <= ? and id != ?", 
                                    ind.id, Date.today, destroy ? ih.id : -1).order("day desc").first
                                    
    if (!latest.nil? && (
          ind.value.nil? || 
          (destroy && !ind.last_update.nil? && ind.last_update == ih.day)  || 
          (!ind.last_update.nil? && ind.last_update <= latest.day)
      ))
      ind.update_columns(value: latest.value) unless ind.value == latest.value
      ind.update_columns(goal: latest.goal) unless latest.goal.nil? || ind.goal == latest.goal
      ind.update_columns(last_update: latest.day) unless ind.last_update == latest.day
      ind.touch
    end
    
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
  
  def compute_next_update(indicator)
    next_update_after(indicator.last_update, indicator.frequency)
  end
  
  def next_update_after(d, freq)
    return nil if d.nil?
    n = d
    l = d
    while (l >= n || Date.today >= n)
      n += increment(freq)
    end
    n
  end
  
  def increment(freq)
    case freq
    when "weekly"
      1.week
    when "monthly"
      1.month
    when "quarterly"
      3.month
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
    acting_user.administrator? || same_company_admin || same_creator || hoshin_creator
  end

  def view_permitted?(field=nil)
    acting_user.administrator? || same_company
  end
  
end

class ChildIndicator < Indicator
end