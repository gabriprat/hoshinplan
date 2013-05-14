class IndicatorHistory < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    value :decimal
    day   :date
    timestamps
  end
  attr_accessible :value, :indicator, :indicator_id, :date

  belongs_to :indicator, :inverse_of => :indicator_histories, :counter_cache => false

  validates_uniqueness_of :day, :scope => [:indicator_id]

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
