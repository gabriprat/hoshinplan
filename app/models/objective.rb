class Objective < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name        :string
    description :text
    responsible :string
    indicators_count :integer, :default => 0, :null => false
    tasks_count :integer, :default => 0, :null => false
    timestamps
  end
  attr_accessible :name, :area, :area_id, :description, :responsible, :indicators, :tasks, :hoshin, :hoshin_id

  has_many :indicators, :dependent => :destroy, :inverse_of => :objective
  has_many :tasks, :dependent => :destroy, :inverse_of => :objective, :order => 'position'

  children :indicators, :tasks

  belongs_to :area, :inverse_of => :objectives, :counter_cache => false
  belongs_to :hoshin, :inverse_of => :objectives
  
  acts_as_list :scope => :area
  
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
