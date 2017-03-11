class PaymentNotification < ApplicationRecord

  hobo_model # Don't put anything above this

  fields do
    response :string
    raw_post :text
    timestamps
  end
  attr_accessible :response, :raw_post

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
