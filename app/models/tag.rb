class Tag < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    label :string, name: true
    timestamps
  end
  index [:label]

  attr_accessible :label

  belongs_to :hoshin, :null => false
  belongs_to :creator, :class_name => "User", :creator => true

  # --- Permissions --- #

  def create_permitted?
   true || acting_user.administrator? || same_company_editor
  end

  def update_permitted?
    true || acting_user.administrator? || same_company_editor
  end

  def destroy_permitted?
    true || acting_user.administrator? || same_company_admin || same_creator || hoshin_creator
  end

  def view_permitted?(field=nil)
    true || acting_user.administrator? || same_company
  end

end