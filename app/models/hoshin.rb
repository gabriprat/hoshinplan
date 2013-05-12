class Hoshin < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name :string
    areas_count :integer, :default => 0, :null => false
    timestamps
  end
  attr_accessible :name, :id, :parent, :parent_id, :company
  attr_accessible :areas, :children, :children_ids

  belongs_to :company, :inverse_of => :hoshins, :counter_cache => true
  belongs_to :parent, :class_name => "Hoshin"
  has_many :children, :class_name => "Hoshin", :foreign_key => "parent_id", :dependent => :destroy
  
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
