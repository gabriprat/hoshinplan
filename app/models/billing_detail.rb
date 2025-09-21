class BillingDetail < ApplicationRecord

  acts_as_paranoid

  include ModelBase

  hobo_model # Don't put anything above this

  self.primary_key = "id"

  fields do
    company_name :string, :required
    address_line_1 :string, :required
    address_line_2 :string
    city :string, :required
    state :string, :required
    zip :string, :required
    contact_name :string, :required
    contact_email :email_address, :required
    send_invoice_cc :string
    vat_number HoboFields::Types::Vat
    vies_valid :boolean, :default => false
    country HoboFields::Types::Country, :required
    stripe_client_id :string
    sage_one_contact_id :string
    sage_active_third_party_id :string
    chargebee_id :string, :unique, :index => true
    card_name :string
    card_brand :string
    card_last4 :string
    card_exp_month :integer
    card_exp_year :integer
    card_stripe_token :string
    stripe_payment_method :string
    timestamps
    deleted_at    :datetime
  end

  index [:company_id], :unique => true

  attr_accessible :id, :company_name, :contact_name, :contact_email, :address_line_1, :address_line_2, :city, :state,
                  :zip, :country, :vat_number, :stripe_client_id, :card_brand, :card_name, :card_last4, :card_exp_month,
                  :card_exp_year, :card_stripe_token, :company_id, :creator_id, :vies_valid, :sage_one_contact_id,
                  :stripe_payment_method, :chargebee_id

  set_search_columns :company_name, :contact_name, :contact_email, :vat_number


  validates :company_id, :uniqueness => true, allow_nil: true
  validate :validate_vat_number

  belongs_to :creator, :class_name => "User", :creator => true
  belongs_to :company, inverse_of: :billing_details, primary_key: "id"

  has_many :subscriptions, inverse_of: :billing_detail
  has_many :invoices, -> {order created_at: :desc}, :inverse_of => :subscription


  before_save do |record|
    if record.country_changed? || record.vat_number_changed?
      country = record.country.alpha2
      vn = Valvat.new(country + record.vat_number.to_s)
      if record.eu?
        vv = vn.exist?(raise_error: true)
        record.vies_valid = vv
      else
        record.vies_valid = true
      end
    end
    true
  end

  def eu?
    Valvat::Utils::EU_MEMBER_STATES.include?(country)
  end

  def validate_vat_number
    if eu? && !vat_number.empty?
      vn = Valvat.new(country + vat_number)
      # Only validate format, not VIES existence
      # VIES validation is done separately for tax calculation purposes
      errors.add(:vat_number, I18n.t('errors.not_expected_format')) unless vn.valid?
    end
  end

  def active_subscription
    Subscription.where(status: 'Active', company_id: company_id).first_or_initialize
  end

  def active_subscription=(s2)
    s = active_subscription
    s.user = creator
    with_acting_user(creator) do
      s.attributes = s2
    end
    s.company_id = company_id
    s.billing_detail_id = id
    subscriptions << s
  end

  def tax_tpc
    is_spain = country.alpha2 == 'ES'
    is_canary_islands = is_spain && %w[35 38].include?((zip||'')[0..1])
    !is_canary_islands && (is_spain || country.in_eu? && !vies_valid) ? country.vat_rates['standard'] : 0
  end

  # --- Permissions --- #

  def create_permitted?
    true
  end

  def update_permitted?
    acting_user.administrator? || same_company_admin
  end

  def destroy_permitted?
    acting_user.administrator? || same_company_admin
  end

  def view_permitted?(field)
    acting_user.administrator? || self.new_record? || same_company_admin
  end

end
