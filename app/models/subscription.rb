class Subscription < ActiveRecord::Base

  acts_as_paranoid

  include ModelBase

  hobo_model # Don't put anything above this

  fields do
    id_paypal       :string
    status          :string, default: 'Active'
    sandbox         :boolean
    plan_name       :string, :required
    amount_value    :decimal, :required, :precision => 8, :scale => 2
    monthly_value   :decimal, :required, :precision => 8, :scale => 2
    amount_currency :string, :required
    users           :integer, :required
    billing_period  HoboFields::Types::EnumString.for(:monthly, :annual), :required
    last_payment_at :datetime
    next_payment_at :date
    paying_at       :datetime
    payment_error   :text
    timestamps
    deleted_at      :datetime
    deleted_by      :string
  end
  index [:deleted_at]
    
  validates :company_id, :presence => true
  validates :user_id, :presence => true
  
  validate :only_one_active_subscription
  
  after_validation do |s|
    fail s.errors.to_yaml if !errors.blank?
  end
  
  
  attr_accessible :user, :user_id, :status, :token, :sandbox, :amount_value, :monthly_value, 
    :amount_currency, :plan_name, :company, :company_id, :users, :billing_period
    
  belongs_to :user, :inverse_of => :subscriptions
  belongs_to :company, :inverse_of => :subscriptions 
  belongs_to :billing_detail, :inverse_of => :subscriptions
  belongs_to :billing_plan, :inverse_of => :subscriptions
  
  after_save :update_counter_cache
  after_destroy :update_counter_cache
  after_create :update_counter_cache


  scope :at_hour, lambda { |*hour|
    joins(:user)
        .where("date_part('hour',now() at time zone coalesce(users.timezone, 'Europe/Berlin')) = ?", hour)
        .references(:user)

  }

  before_save do |s|
    if s.status_changed? && s.status == 'Canceled'
      s.deleted_by = User.current_user.email_address
    end
  end

  before_create do |s|
    self.next_payment_at = DateTime.now.end_of_month + 1.day
  end
  
  after_initialize do 
    self.sandbox = !Rails.env.production? if (self.has_attribute? :sandbox) && self.sandbox.nil?
  end
  
  def only_one_active_subscription
    if status=='Active' && Subscription.where(company_id: company_id, status: status).where.not(id: id).exists?
      errors.add(:company_id, "can't have more than one subscription")
    end
  end
  
  def update_counter_cache
    u = User.unscoped.find(user_id)
    u.subscriptions_count = u.subscriptions.where(:status => :Active).count
    u.save!
    c = Company.unscoped.find(company_id)
    c.subscriptions_count = c.subscriptions.where(:status => :Active).count
    c.save!
  end

  before_create :set_next_payment_at_to_now
  def set_next_payment_at_to_now
    self.next_payment_at ||= Time.now
  end

  def remaining_amount
    return 0 if self.new_record?
    (total_amount * remaining_time_fraction).round(2)
  end

  def remaining_time_fraction
    return 0 if self.new_record?
    remaining_days.to_f / total_days.to_f
  end

  def total_amount
    return 0 if self.new_record?
    amount_per_user_per_period * users
  end

  def amount_per_user_per_period
    return 0 if self.new_record?
    if billing_period == :monthly
      monthly_value
    else
      amount_value * 12
    end
  end

  def total_days
    return 0 if self.new_record?
    if (last_payment_at.nil?)
      start = next_payment_at - (billing_period == :monthly ? 1.month : 1.year)
    else
      start = last_payment_at
    end
    (next_payment_at.to_date - start).to_i
  end

  def remaining_days
    return 0 if self.new_record?
    (next_payment_at.to_date - Date.today).to_i
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

  def charge(full_amount=true, old_remaining_amount=0)
    c = Company.unscoped.find(company_id)
    b = BillingDetail.unscoped.find(billing_detail_id)
    credit = c.credit || 0;
    charge_amount = full_amount ? total_amount : remaining_amount
    pay_now = charge_amount - old_remaining_amount - credit;
    pay_now = pay_now * (1.0 + b.tax_tpc.to_f/100.0)
    if pay_now > 0
      order = Stripe::Charge.create(
          amount: (pay_now * 100).to_i,
          currency: amount_currency,
          customer: b.stripe_client_id,
          description: plan_name + " plan #{billing_period} (#{users} users)"
      )
      c.credit = 0
      c.save
    else
      c.credit = -pay_now
      c.save
    end
    pay_now
  end
end


