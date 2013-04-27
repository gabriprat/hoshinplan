class IndicatorHistory < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    value :decimal
    timestamps
  end
  attr_accessible :value, :indicator, :indicator_id

  belongs_to :indicator, :inverse_of => :indicator_historys, :counter_cache => false

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
