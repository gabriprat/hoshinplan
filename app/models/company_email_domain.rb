class CompanyEmailDomain < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    timestamps
    domain :string, :name => true
  end
  index [:domain, :company_id]  
  
  attr_accessible :domain, :accessible => true

  belongs_to :company

  # --- Permissions --- #

  def create_permitted?
    true
  end

  def update_permitted?
    self.new_record? || company.update_permitted?
  end

  def destroy_permitted?
    self.new_record? || company.destroy_permitted?
  end

  def view_permitted?(field)
    true
  end

end