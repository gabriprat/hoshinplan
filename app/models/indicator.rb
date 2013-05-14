class Indicator < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name        :string
    value       :decimal
    description :text
    higher      :boolean, :default => true
    frequency   :string
    next_update :date
    last_update :date
    last_value  :decimal
    goal        :decimal, :default => 100.0
    min_value   :decimal, :default => 0.0
    max_value   :decimal, :default => 100.0
    timestamps
  end
  attr_accessible :name, :objective, :objective_id, :value, :description, :responsible, :responsible_id, 
    :higher, :frequency, :next_update, :goal, :min_value, :max_value, :area, :area_id, :trend

  has_many :indicator_histories, :dependent => :destroy, :inverse_of => :indicator

  belongs_to :objective, :inverse_of => :indicators, :counter_cache => true
  belongs_to :area, :inverse_of => :tasks, :counter_cache => false
  belongs_to :responsible, :class_name => "User", :inverse_of => :indicators
  
  acts_as_list :scope => :area
 
  before_update do |indicator|
    #if indicator.last_update < Date.today
      indicator.last_value = indicator.value_was
      ih = indicator.indicator_histories.where(:day => Date.today).first
      if ih.nil?
        ih = IndicatorHistory.create
        ih.indicator_id = indicator.id
        ih.day = Date.today
      end
      ih.value = indicator.value
      ih.save!
      #end
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
        ((last_value < value && higher) || (value < last_value && !higher)) ? :positive : :negative
      end
    end
  end
    
  
  def tpc 
    ret = 0
    if !max_value.nil? && !min_value.nil? && !value.nil? && (max_value-min_value)!=0
      if higher
        ret = 100 * (value-min_value) / (goal-min_value)
      else
        ret = 100 * ((max_value-value) / (max_value-goal))
      end 
    end 
  end
  # --- Permissions --- #

  def create_permitted?
    acting_user.administrator?
  end

  def update_permitted?
    acting_user.administrator?
  end

  def destroy_permitted?
    acting_user.administrator?
  end

  def view_permitted?(field)
    true
  end

end
