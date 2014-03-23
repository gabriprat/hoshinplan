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

  # --- Permissions --- #

  def create_permitted?
    same_company
  end

  def update_permitted?
    same_company
  end

  def destroy_permitted?
    same_company
  end

  def view_permitted?(field)
    same_company
  end

end
