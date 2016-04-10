class BillingPlan < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name            :string
    description     :string
    brief           :string
    users           :integer
    features        :text
    frequency       HoboFields::Types::EnumString.for(:WEEK, :DAY, :YEAR, :MONTH)
    interval        :integer
    amount_currency :string
    amount_value    :decimal, :precision => 8, :scale => 2
    id_paypal       :string
    status_paypal   HoboFields::Types::EnumString.for(:CREATED, :ACTIVE, :INACTIVE, :DELETED)
    css_class       :string
    workers         :integer
    stripe_id       :string
    timestamps
  end
  attr_accessible :name, :description, :brief, :users, :css_class, :features, 
    :frequency, :interval, :amount_currency, :amount_value, :id_paypal, :status_paypal, :workers, :stripe_id

  has_many :payments, :inverse_of => :billing_plan
  acts_as_list
    
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
