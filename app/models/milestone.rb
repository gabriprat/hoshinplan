class Milestone < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    value :decimal
    date  :date
    timestamps
  end
  attr_accessible :value, :date

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
