class Indicator < ActiveRecord::Base

  include ModelBase
  
  hobo_model # Don't put anything above this

  fields do
    name        :string
    value       :decimal
    description :text
    frequency   HoboFields::Types::EnumString.for(:weekly, :monthly, :quarterly)
    next_update :date
    last_update :date
    last_value  :decimal
    goal        :decimal, :default => 100.0
    worst_value :decimal, :default => 0.0
    reminder    :boolean, :default => true
    timestamps
  end
  attr_accessible :name, :objective, :objective_id, :value, :description, :responsible, :responsible_id, :reminder,
   :frequency, :next_update, :goal, :worst_value, :area, :area_id, :trend, :company, :company_id

  has_many :indicator_histories, :dependent => :destroy, :inverse_of => :indicator, :conditions => "indicator_histories.value is not null"
  
  belongs_to :company

  belongs_to :objective, :inverse_of => :indicators, :counter_cache => true
  belongs_to :area, :inverse_of => :indicators, :counter_cache => false
  belongs_to :responsible, :class_name => "User", :inverse_of => :indicators
  
  acts_as_list :scope => :area, :column => "ind_pos"
  
  validate :validate_company
  
  default_scope lambda { 
    where(:company_id => UserCompany.select(:company_id)
      .where('user_id=?',  
        User.current_id) ) }
 
  before_create do |indicator|
    indicator.company = indicator.objective.company
  end
  
  before_update do |indicator|
    if !indicator.next_update_changed?
      indicator.next_update = compute_next_update(indicator)
    end
    #if indicator.value_changed?
      indicator.last_value = indicator.value_was
      ih = IndicatorHistory.unscoped.where(:day => Date.today, :indicator_id => indicator.id).first
      if ih.nil?
        ih = IndicatorHistory.create
        ih.indicator = indicator
        ih.day = Date.today
      end
      ih.value = indicator.value
      ih.goal = indicator.goal
      ih.save!
    #end
  end
  
  def position
    ind_pos
  end
  
  def status 
    if !next_update.nil?
      next_update < Date.today ? :overdue : :current
    end
  end
  
  def trend
    if last_value.nil?
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
    worst_value < goal
  end
  
  def tpc 
    ret = 0
    if !worst_value.nil? && !value.nil? && (goal-worst_value)!=0
      ret = 100 * (value-worst_value) / (goal-worst_value)
    end 
  end
  
  def compute_next_update(indicator)
    t = Time.now
    case indicator.frequency
    when "weekly"
      t + 1.week
    when "monthly"
      t + 1.month
    when "quarterly"
      t + 3.month
    end
  end
  
  # --- Permissions --- #
  
  def validate_company
    errors.add(:company, "You don't have permissions on this company") unless same_company
  end
  
  def create_permitted?
    same_company
  end

  def update_permitted?
    true #same_company
  end

  def destroy_permitted?
    same_company
  end

  def view_permitted?(field)
    true #same_company
  end
  
end
