class Area < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name        :string
    description :text
    timestamps
  end

  attr_accessible :name, :description, :hoshin, :hoshin_id

  has_many :objectives, :dependent => :destroy, :inverse_of => :area, :order => 'position'
  has_many :indicators, :through => :objectives, :accessible => true, :order => 'position'
  has_many :tasks, :through => :objectives, :accessible => true, :order => 'position'

  belongs_to :hoshin, :inverse_of => :areas, :counter_cache => true
  
  acts_as_list :scope => :hoshin
  
  def child_tasks 
    child_hoshins = hoshin.children.*.id
    return nil unless child_hoshins
    child_objectives = Objective.where(:parent_id => objectives.*.id)
    ChildTask.where(:objective_id => child_objectives, :show_on_parent => true)
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
