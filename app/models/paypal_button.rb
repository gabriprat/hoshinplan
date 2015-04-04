class PaypalButton < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    product           :string, required: true, index: true, unique: true
    id_paypal         :string, required: true
    id_paypal_sandbox :string
    timestamps
  end
  attr_accessible :product, :id_paypal, :id_paypal_sandbox

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
