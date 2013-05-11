class Company < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name :string
    hoshins_count :integer, :default => 0, :null => false
    timestamps
  end
  attr_accessible :name
  
  has_many :hoshins, :dependent => :destroy, :inverse_of => :company, :order => :name
  
  children :hoshins

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
