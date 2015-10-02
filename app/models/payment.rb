class Payment < ActiveRecord::Base

  acts_as_paranoid

  include ModelBase

  hobo_model # Don't put anything above this

  fields do
    token           :string, :required, :index => true, :unique => true
    id_paypal       :string
    status          :string
    sandbox         :boolean
    amount_value    :decimal, :precision => 8, :scale => 2
    amount_currency :string
    timestamps
    deleted_at    :datetime
  end
  index [:deleted_at]
  
  attr_accessible :user, :user_id, :status, :token, :sandbox, :amount_value, :amount_currency, :billing_plan, :company, :billing_plan_id, :company_id
    
  belongs_to :user, :inverse_of => :payments, :counter_cache => true
  belongs_to :company, :inverse_of => :payments
  belongs_to :billing_plan, :inverse_of => :payments

  # --- Permissions --- #

  def create_permitted?
    acting_user.administrator? || same_company
  end

  def update_permitted?
    acting_user.administrator? || same_company 
  end

  def destroy_permitted?
    acting_user.administrator? || same_company_admin
  end

  def view_permitted?(field=nil)
    acting_user.administrator? || same_company
  end

end
