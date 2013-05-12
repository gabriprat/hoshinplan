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
  attr_accessible :name, :area, :area_id, :description, :responsible, 
    :indicators, :tasks, :hoshin, :hoshin_id, :parent, :parent_id

  has_many :indicators, :dependent => :destroy, :inverse_of => :objective
  has_many :tasks, :dependent => :destroy, :inverse_of => :objective, :order => 'position'

  children :indicators, :tasks

  belongs_to :parent, :class_name => "Objective"
  belongs_to :area, :inverse_of => :objectives, :counter_cache => false
  belongs_to :hoshin, :inverse_of => :objectives
  
  acts_as_list :scope => :area
  
  def parent_hoshin
    ret = area.hoshin.parent_id
    ret.nil? ? 0 : ret
  end

  def parent_objectives
    result = Objective.find_all_by_hoshin_id(parent_hoshin)
  end
  
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
