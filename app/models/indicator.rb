class Indicator < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name        :string
    value       :decimal
    description :text
    responsible :string
    higher      :boolean
    frequency   :string
    next_update :date
    goal        :decimal
    max_value   :decimal
    timestamps
  end
  attr_accessible :name, :objective, :objective_id, :value, :description, :responsible, 
    :higher, :frequency, :next_update, :goal, :max_value, :area, :area_id

  has_many :indicator_historys, :dependent => :destroy, :inverse_of => :indicator

  belongs_to :objective, :inverse_of => :indicators, :counter_cache => true
  belongs_to :area, :inverse_of => :tasks, :counter_cache => false
  
  acts_as_list :scope => :area

  def tpc 
    if value?
      if higher?
        100 * value / goal
      else
        100 * ((value-max_value) / (goal-max_value))
      end 
    else
      0
    end 
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
