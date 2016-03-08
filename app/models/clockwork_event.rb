class ClockworkEvent < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name               :string
    job                :string
    frequency_quantity :integer
    frequency_period   HoboFields::Types::EnumString.for(:second, :minute, :hour, :day, :week, :month)
    at                 :string
    options            :string 
    timestamps
  end
  attr_accessible :name, :job, :frequency_quantity, :frequency_period, :at, :options
  
  # Used by clockwork to schedule how frequently this event should be run
  # Should be the intended number of seconds between executions
  def frequency
    frequency_quantity.send(frequency_period.to_s)
  end
  
  def jobClass
    ::Jobs.const_get(job)
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
