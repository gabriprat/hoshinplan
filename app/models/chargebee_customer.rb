class ChargebeeCustomer < ApplicationRecord
  include ModelBase

  hobo_model # Don't put anything above this
  
  fields do
    chargebee_id :string
    sage_id  :string
    timestamps
  end
  attr_accessible :id, :sage_id, :chargebee_id

  # --- Permissions --- #

  def create_permitted?
    true
  end

  def update_permitted?
    true
  end

  def destroy_permitted?
    true
  end

  def view_permitted?(field)
    true
  end

end