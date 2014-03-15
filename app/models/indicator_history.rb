class IndicatorHistory < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    value :decimal
    goal  :decimal
    day   :date
    timestamps
  end
  attr_accessible :value, :goal, :indicator, :indicator_id, :day

  belongs_to :indicator, :inverse_of => :indicator_histories, :counter_cache => false

  validates_uniqueness_of :day, :scope => [:indicator_id]

  # --- Permissions --- #

  def create_permitted?
    true
  end

  def update_permitted?
    acting_user.administrator?
  end

  def destroy_permitted?
    true
  end

  def view_permitted?(field)
    true
  end

end
