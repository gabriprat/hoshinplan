class IndicatorHistory < ActiveRecord::Base

  hobo_model # Don't put anything above this
  
  include ModelBase

  fields do
    value :decimal
    goal  :decimal
    day   :date
    timestamps
  end
  attr_accessible :value, :goal, :indicator, :indicator_id, :day, :creator_id
  
  belongs_to :creator, :class_name => "User", :creator => true
  
  belongs_to :company

  belongs_to :indicator, :inverse_of => :indicator_histories, :counter_cache => false

  validates_uniqueness_of :day, :scope => [:indicator_id]
  
  before_create do |ih|
    ih.company = ih.indicator.company
  end
  
  after_save do |ih|
    latest = IndicatorHistory.where("indicator_id = ? and day <= ?", indicator_id, Date.today).order("day desc").first
    ind = ih.indicator
    if (ind.value.nil? || (!ind.last_update.nil? && ind.last_update <= latest.day))
      ind.value = latest.value
      ind.goal  = latest.goal
      ind.save!
    end
  end
  

  # --- Permissions --- #

  def create_permitted?
    same_company
  end

  def update_permitted?
    indicator.update_permitted?
  end

  def destroy_permitted?
    indicator.destroy_permitted?
  end

  def view_permitted?(field)
    indicator.view_permitted?
  end

end
