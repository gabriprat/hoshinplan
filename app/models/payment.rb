class Payment < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    raw_post :text
    txn_id   :string, :required, :index => true, :unique => true
    status   :string
    product  :string
    sandbox  :boolean
    timestamps
  end
  attr_accessible :user, :user_id, :raw_post, :status, :txn_id, :product
  
  belongs_to :user, :inverse_of => :payments

  # --- Permissions --- #

  def create_permitted?
    true
  end

  def update_permitted?
    acting_user.administrator?
  end

  def destroy_permitted?
    acting_user.administrator?
  end

  def view_permitted?(field)
     acting_user.administrator?
  end

end
