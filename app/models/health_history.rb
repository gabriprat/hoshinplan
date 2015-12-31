class HealthHistory < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    day               :date
    objectives_health :decimal
    indicators_health :decimal
    tasks_health      :decimal
    timestamps
  end
  index [:hoshin_id, :day], :unique => true
  
  attr_accessible :day, :objectives_health, :indicators_health, :tasks_health
  
  belongs_to :hoshin, :inverse_of => :health_histories, :counter_cache => false, :null => false
  belongs_to :company, :null => false
   
  before_create do |hh|
    hh.company = hh.hoshin.company
  end
  # --- Permissions --- #

  def create_permitted?
    same_company
  end

  def update_permitted?
    hoshin.updatable_by?(acting_user)
  end

  def destroy_permitted?
    hoshin.destroyable_by?(acting_user)
  end

  def view_permitted?(field)
    self.new_record? || hoshin.viewable_by?(acting_user)
  end

end
