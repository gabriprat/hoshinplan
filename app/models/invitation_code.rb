class InvitationCode < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name        :string, :unique, :null => false
    total       :integer, :null => false
    used        :integer, :null => false
    trial_days  :integer, :null => false
    start_at    :date, :null => false
    end_at      :date, :null => false
    timestamps
  end

  scope :available, lambda {|*name_param|
    where("name = ? and now() between start_at and end_at and used < total", name_param)
  }


  def remaining
    total - used
  end

  # --- Permissions --- #

  def create_permitted?
    acting_user.administrator?
  end

  def update_permitted?
    acting_user.administrator || !name_changed? && !total_changed? && !trial_days_changed?
  end

  def destroy_permitted?
    acting_user.administrator?
  end

  def view_permitted?(field)
    true
  end
end