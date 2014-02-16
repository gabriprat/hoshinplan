class OpenidProvider < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    email_domain :string
    openid_url    :string
    timestamps
  end
  attr_accessible :email_domain, :openid_url

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
