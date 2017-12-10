class Subscription < ApplicationRecord

  acts_as_paranoid

  include ModelBase

  hobo_model # Don't put anything above this

  fields do
    id_paypal :string
    status :string, default: 'Active'
    sandbox :boolean
    plan_name :string, :required
    amount_value :decimal, :required, :precision => 8, :scale => 2
    monthly_value :decimal, :required, :precision => 8, :scale => 2
    amount_currency :string, :required
    users :integer, :required
    billing_period HoboFields::Types::EnumString.for(:monthly, :annual), :required
    last_payment_at :datetime
    next_payment_at :date
    paying_at :datetime
    payment_error :text
    per_user :boolean, default: true, null: false
    timestamps
    deleted_at :datetime
    deleted_by :string
  end
  index [:deleted_at]

  validates :company_id, :presence => true
  validates :user_id, :presence => true

  validate :only_one_active_subscription

  validates :users, numericality: {greater_than_or_equal_to: 10}

  attr_accessible :user, :user_id, :status, :token, :sandbox, :amount_value, :monthly_value,
                  :amount_currency, :plan_name, :company, :company_id, :users, :billing_period

  belongs_to :user, :inverse_of => :subscriptions
  belongs_to :company, :inverse_of => :subscriptions
  belongs_to :billing_detail, :inverse_of => :subscriptions, primary_key: "id"
  belongs_to :billing_plan, :inverse_of => :subscriptions

  has_many :invoices, :inverse_of => :subscription

  after_save :update_counter_cache
  after_destroy :update_counter_cache
  after_create :update_counter_cache

  default_scope lambda {
    where(:company_id => UserCompany.select(:company_id)
                             .where('user_id=?',
                                    User.current_id)
    )
  }

  scope :at_hour, lambda {|*hour|
    joins(:user)
        .where("date_part('hour',now() at time zone coalesce(users.timezone, 'Europe/Berlin')) = ?", hour)
        .references(:user)

  }

  before_destroy do |s|
    s.status = 'Canceled'
    s.deleted_by = User.current_user.email_address
    s.save!(validate: false)
  end

  before_save do |s|
    if s.status_changed? && s.status == 'Canceled'
      s.deleted_by = User.current_user.email_address
    end

    if s.billing_period_changed?
      s.next_payment_at = DateTime.now.end_of_month + 1.day
    end
  end

  before_create do |s|
    self.type = 'SubscriptionStripe'
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
    u.subscriptions_count = Subscription.unscoped.where(user_id: user_id, status: :Active).count
    u.save!
    c = Company.unscoped.find(company_id)
    c.subscriptions_count = Subscription.unscoped.where(company_id: company_id, status: :Active).count
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
    amount_per_user_per_period * (per_user ? users : 1)
  end

  def amount_per_user_per_period
    return 0 if self.new_record?
    if billing_period == :monthly
      monthly_value
    else
      amount_value * 12
    end
  end

  def period_start_at
    last_payment_at.nil? ? Date.today : last_payment_at
  end

  def period_ends_at
    next_payment_at
  end

  def total_days
    return 0 if self.new_record?
    if (last_payment_at.nil?)
      start = next_payment_at - (billing_period == :monthly ? 1.month : 1.year)
    else
      start = last_payment_at
    end
    (next_payment_at.to_date - start.to_date).to_i
  end

  def remaining_days
    return 0 if self.new_record?
    ret = (next_payment_at.to_date - Date.today).to_i
    ret < 0 ? total_days : ret
  end

  def pay_now(full_amount=true, old_remaining_amount=0)
    b = BillingDetail.unscoped.find(billing_detail_id)
    c = Company.unscoped.find(company_id)
    credit = c.credit || 0
    charge_amount = full_amount ? total_amount : remaining_amount
    ret = charge_amount - old_remaining_amount
    ret = ret * (1.0 + b.tax_tpc.to_f/100.0)
    ret = ret - credit
    ret
  end

  def compute_next_payment_at
    days_to_add = case billing_period
                    when 'annual' then
                      1.year
                    when 'monthly' then
                      1.month
                    else
                      raise TypeError, "Unknown billing period #{s.billing_period}"
                  end
    next_payment_at + days_to_add
  end

  def billing_description
    start_at = period_start_at.to_date
    end_at = period_ends_at.to_date
    if start_at == end_at
      end_at =  compute_next_payment_at
    end
    plan_name + " plan #{billing_period} (#{users} users) from #{start_at} to #{end_at}"
  end

  # --- Permissions --- #

  def create_permitted?
    acting_user.administrator? || same_company_admin
  end

  def update_permitted?
    acting_user.administrator? || same_company_admin
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
    if self.id_paypal
      agreement = PaypalAccess.find_agreement(self.id_paypal)
      agreement.cancel(note: "Canceled through Hoshinplan.com by " + User.current_user.email_address)
    end
    self.status = 'Canceled'
    self.save!(validate: false)
  end

  def next_payment_at
    today = Date.today
    if today.day > created_at.day
      next_payment = today + 1.month
    else
      next_payment = today
    end
    next_payment.change(day: created_at.day)
  end
end

class SubscriptionStripe < Subscription
  def cancel
    self.status = 'Canceled'
    self.save!(validate: false)
  end

  def charge(full_amount=true, old_remaining_amount=0, remote_ip='')
    c = Company.unscoped.find(company_id)
    b = BillingDetail.unscoped.find(billing_detail_id)
    pay_now_amount = pay_now(full_amount, old_remaining_amount).round(2)
    if pay_now_amount > 0
      order = Stripe::Charge.create(
          amount: (pay_now_amount * 100).to_i,
          currency: amount_currency,
          customer: b.stripe_client_id,
          description: billing_description
      )
      c.credit = 0
      c.save
      i = invoices.create
      i.total_amount = pay_now_amount
      i.description = billing_description
      i.tax_tpc = b.tax_tpc
      i.net_amount = pay_now_amount / (1.0 + b.tax_tpc.to_f/100.0)
      i.save

      Mp.track_charge(user, remote_ip, pay_now)
    else
      c.credit = -pay_now_amount
      c.save
    end
    pay_now_amount
  end
end


