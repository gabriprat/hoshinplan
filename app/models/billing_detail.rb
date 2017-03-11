class BillingDetail < ApplicationRecord

  acts_as_paranoid

  include ModelBase

  hobo_model # Don't put anything above this

  fields do
    company_name :string, :required
    address_line_1 :string, :required
    address_line_2 :string
    city :string, :required
    state :string, :required
    zip :string, :required
    contact_name :string, :required
    contact_email :email_address, :required
    vat_number HoboFields::Types::Vat
    vies_valid :boolean, :default => false
    country HoboFields::Types::Country, :required
    stripe_client_id :string
    card_brand :string
    card_last4 :string
    card_exp_month :integer
    card_exp_year :integer
    card_stripe_token :string
    timestamps
    deleted_at    :datetime
  end

  index [:company_id], :unique => true
  
  attr_accessible :company_name, :contact_name, :contact_email, :address_line_1, :address_line_2, :city, :state, :zip, :country,
    :vat_number, :stripe_client_id, :card_brand, :card_last4, :card_exp_month, :card_exp_year, :card_stripe_token, :plan_name, 
    :price_per_user, :users, :billing_period, :active_subscription, :company_id, :creator_id, :vies_valid
    
  validates :company_id, :presence => true, :uniqueness => true
  validates :vat_number, vat: {country_method: :country, message: proc {I18n.t('errors.not_expected_format')}}, allow_blank: true
  
  belongs_to :creator, :class_name => "User", :creator => true
  belongs_to :company, :inverse_of => :billing_details
  
  has_many :subscriptions, inverse_of: :billing_detail

  before_save do |record|
    if record.country_changed? || record.vat_number_changed?
      country = record.country.alpha2
      vat_number = ::ActiveModel::Validations::VatNumber.new(country + record.vat_number, country)
      if vat_number.can_validate?
        begin
          vv = ::VatValidations::ViesChecker.check(country + record.vat_number, false)
        rescue VatValidations::ViesContactError
          vv = false
        end
        record.vies_valid = vv
      else
        record.vies_valid = true
      end
    end
    true
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
    country.alpha2 == 'ES' || country.in_eu? && !vies_valid ? country.vat_rates['standard'] : 0
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
