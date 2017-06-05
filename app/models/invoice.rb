class Invoice < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    sage_one_invoice_id :string
    description :string, :required
    net_amount :decimal, :required, :precision => 8, :scale => 2
    tax_tpc :decimal, :required, :precision => 8, :scale => 2
    total_amount :decimal, :required, :precision => 8, :scale => 2
    timestamps
  end
  attr_accessible :description, :net_amount, :tax_tpc, :total_amount

  belongs_to :subscription, :inverse_of => :invoices

  default_scope lambda {
    joins(:subscription)
  }

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
