class Area < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name        :string
    description :text
    #objectives_count :integer, :default => 0, :null => false
    timestamps
  end
  attr_accessible :name, :description, :objectives

  has_many :objectives, :dependent => :destroy, :inverse_of => :area
  has_many :indicators, :through => :objectives, :accessible => true
  has_many :tasks, :through => :objectives, :accessible => true

  children :objectives

  belongs_to :hoshin, :inverse_of => :areas, :counter_cache => true

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
