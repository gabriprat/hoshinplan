class IndicatorHistory < ActiveRecord::Base

  hobo_model # Don't put anything above this
  
  include ModelBase

  fields do
    value :decimal
    goal  :decimal
    day   :date
    timestamps
  end
  index [:indicator_id, :day]
  
  attr_accessible :value, :goal, :indicator, :indicator_id, :day, :creator_id
  
  belongs_to :creator, :class_name => "User", :creator => true
  
  belongs_to :company

  belongs_to :indicator, :inverse_of => :indicator_histories, :counter_cache => false

  belongs_to :responsible, :class_name => "User", :inverse_of => :indicator_histories  

  validates_uniqueness_of :day, :scope => [:indicator_id]
  
  before_create do |ih|
    ih.company = ih.indicator.company
  end

  before_destroy do |ih|
    ind = Indicator.find(ih.indicator_id)
    ind.update_from_history!(destroy=true, ih=ih)
  end

  # --- Permissions --- #

  def create_permitted?
    same_company
  end

  def update_permitted?
    indicator.updatable_by?(acting_user)
  end

  def destroy_permitted?
    indicator.destroyable_by?(acting_user)
  end

  def view_permitted?(field)
    indicator.viewable_by?(acting_user)
  end

end
