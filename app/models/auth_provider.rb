class AuthProvider < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    email_domain :string, null: false, name: true
    timestamps
  end
  
  index [:email_domain, :type], unique: true
  
  attr_accessible :email_domain

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