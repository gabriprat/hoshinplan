class Payment < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    raw_post :text
    txn_id   :string, :required, :index => true, :unique => true
    timestamps
  end
  attr_accessible :user, :user_id, :raw_response
  
  belongs_to :user, :inverse_of => :payments

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
