class Subscription < ActiveRecord::Base

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
    deleted_by      :string
  end
  index [:deleted_at]
  
  attr_accessible :user, :user_id, :status, :token, :sandbox, :amount_value, :amount_currency, :billing_plan, :company, :billing_plan_id, :company_id
    
  belongs_to :user, :inverse_of => :subscriptions, inverse_of: :subscriptions
  belongs_to :company, :inverse_of => :subscriptions 
  belongs_to :billing_plan, :inverse_of => :subscriptions
  
  after_save :update_counter_cache
  after_destroy :update_counter_cache
  after_create :update_counter_cache
  
  before_save do |s|
    if s.status_changed? && s.status == 'Canceled'
      s.deleted_by = User.current_user.email_address
    end
  end
  
  def update_counter_cache
    u = self.user
    u.subscriptions_count = u.subscriptions.where(:status => :Active).count
    u.save!
    c = self.company
    c.subscriptions_count = c.subscriptions.where(:status => :Active).count
    c.save!
  end
  
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


class SubscriptionPaypal < Subscription
  def cancel
    if (self.id_paypal)
      agreement = PaypalAccess.find_agreement(self.id_paypal)
      agreement.cancel(note: "Canceled through Hoshinplan.com by " + acting_user.email_address)
    end
    self.status = 'Canceled'
    self.save!
  end
end

class SubscriptionStripe < Subscription
  def cancel
    if (self.token.present? && self.user.stripe_id.present?)
      customer = Stripe::Customer.retrieve(self.user.stripe_id)
      subscription = customer.subscriptions.retrieve(self.token).delete
    end
    self.status = 'Canceled'
    self.save!
  end
end


