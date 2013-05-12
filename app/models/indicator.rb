class Indicator < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name        :string
    value       :decimal
    description :text
    responsible :string
    higher      :boolean
    frequency   :string
    next_update :date
    last_update :date
    last_value  :decimal
    goal        :decimal, :default => 100.0
    min_value   :decimal, :default => 0.0
    max_value   :decimal, :default => 100.0
    timestamps
  end
  attr_accessible :name, :objective, :objective_id, :value, :description, :responsible, 
    :higher, :frequency, :next_update, :goal, :min_value, :max_value, :area, :area_id, :trend

  has_many :indicator_historys, :dependent => :destroy, :inverse_of => :indicator

  belongs_to :objective, :inverse_of => :indicators, :counter_cache => true
  belongs_to :area, :inverse_of => :tasks, :counter_cache => false
  
  acts_as_list :scope => :area
 
  before_update do |indicator|
    #if indicator.last_update < Date.today
      indicator.last_value = indicator.value_was
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
      last_value == value ? :equal : (last_value < value) ? :positive : :negative
    end
  end
    
  
  def tpc 
    ret = 0
    if !max_value.nil? && !min_value.nil? && value? && (max_value-min_value)!=0
      if higher?
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
