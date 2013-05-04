class Hoshin < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name :string
    areas_count :integer, :default => 0, :null => false
    timestamps
  end
  attr_accessible :name, :id
  attr_accessible :areas

  has_many :areas, :dependent => :destroy, :inverse_of => :hoshin, :order => :position
  has_many :objectives, :through => :areas, :accessible => true
  
  children :areas

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
