require 'rest_client'
require 'uri'
require 'sageone_api_signer'

class SageOne < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    access_token :string
    expires_at :datetime
    refresh_token :string
    scopes :string
    requested_by_id :string
    resource_owner_id :string
    timestamps
  end
  attr_accessible :access_token, :expires_at, :refresh_token, :scopes, :requested_by_id, :resource_owner_id
  validate :validate_single_row

  before_create do
    self.expires_at ||= Time.now
  end

  def self.call_api(request_method, endpoint, body_params={})
    SageOne.get.call_api(request_method, endpoint, body_params)
  end

  def call_api(request_method, endpoint, body_params={})
    base_endpoint = SageOne.config[:base_endpoint]
    url = "#{base_endpoint}/#{endpoint}"
    signing_secret = SageOne.config[:signing_secret]

    body_params = put_or_post?(request_method) ? body_params : nil

    signer = SageoneApiSigner.new({
                                      request_method: request_method,
                                      url: url,
                                      body: body_params,
                                      body_params: body_params,
                                      signing_secret: signing_secret,
                                      access_token: self.access_token,
                                      business_guid: self.resource_owner_id
                                  })

    payload = body_params
    header = signer.request_headers("Hoshinplan")

    header["ocp-apim-subscription-key"] = SageOne.config[:apim_subscription_key]
    header["X-Site"] = self.resource_owner_id

    begin
      api_call = RestClient.method(request_method)
      response = put_or_post?(request_method) ? api_call.call(url, payload, header) : api_call.call(url, header)
      request_method == "delete" ? response : JSON.parse(response.to_s)
    rescue
      raise IOError, "#{$!}: #{$!.response}", $!.backtrace
    end
  end

  def self.exchange_code_for_token(code)
    body_params = token_request_body
    body_params << ["code", code]
    body_params << ["grant_type", "authorization_code"]
    body_params << ["redirect_uri", SageOne.config[:callback_url]]

    save_token(body_params)
  end


  def self.create_sales_invoice(invoice)
    subscription = Subscription.unscoped.find(invoice.subscription_id)
    billing_detail = BillingDetail.unscoped.find(subscription.billing_detail_id)
    unless billing_detail.sage_one_contact_id
      response = self.create_contact(billing_detail)
    end
    response = SageOne.call_api(
        "post",
        "accounts/v3/sales_invoices",
        JSON.generate(
            {
                sales_invoice: {
                    contact_id: billing_detail.sage_one_contact_id,
                    date: Date.today,
                    reference: "INV#{invoice.id.to_s.rjust(5, '0')}",
                    main_address: {
                        address_line_1: billing_detail.address_line_1,
                        address_line_2: billing_detail.address_line_2,
                        city: billing_detail.city,
                        region: billing_detail.state,
                        postal_code: billing_detail.zip,
                        country_id: billing_detail.country
                    },
                    invoice_lines: [
                        {
                            description: invoice.description,
                            ledger_account_id: '2ce906040ffc11e7bb3b065b8ec10ed1', #Ventas de mercaderías (70000000)
                            quantity: 1,
                            unit_price: invoice.net_amount,
                            discount_amount: 0,
                            tax_rate_id: billing_detail.country == 'ES' ? 'ES_STANDARD' : 'ES_EXEMPT' #ES_NO_TAX, ES_LOWER_1, ES_LOWER_2
                        }
                    ],
                    net_amount: invoice.net_amount,
                    tax_amount: invoice.total_amount - invoice.net_amount,
                    total_amount: invoice.total_amount
                }
            }
        )
    )
  end

  def self.contacts(page=1, items_per_page=20, search=nil, email=nil)
    endpoint = "accounts/v3/contacts?page=#{page}&items_per_page=#{items_per_page}"
    endpoint += "&search=#{search}" if search
    endpoint += "&email=#{email}" if email
    response = SageOne.call_api(
        "get",
        endpoint)
  end


  def self.contact(id)
    response = SageOne.call_api(
        "get",
        "accounts/v3/contacts/#{id}")
  end

  def self.ledger_accounts(page=1, items_per_page=20)
    response = SageOne.call_api(
        "get",
        "accounts/v3/ledger_accounts?page=#{page}&items_per_page=#{items_per_page}")
  end

  def self.tax_rates(page=1, items_per_page=20)
    response = SageOne.call_api(
        "get",
        "accounts/v3/tax_rates?page=#{page}&items_per_page=#{items_per_page}")
  end

  def self.create_invoices
    company_ids = User.current_user.all_companies.map {|c| c.id}
    subscriptions = Subscription.includes(:billing_plan).where(company_id: company_ids, status: 'Active').references(:billing_plan)
    invoices = Invoice.where(sage_one_invoice_id: nil, subscription_id: subscriptions.map {|s| s.id})
    invoices.each {|invoice|
      create_sales_invoice(invoice)
    }
  end

  def self.create_contact(bd)
    bd ||= BillingDetail.find_by(creator_id: User.current_id)
    response = SageOne.call_api(
        "post",
        "accounts/v3/contacts",
        JSON.generate(
            {
                contact: {
                    contact_type_ids: [
                        'CUSTOMER'
                    ],
                    product_sales_price_type_id: '2cf1d2fa0ffc11e7bb3b065b8ec10ed1', #Precio de venta
                    name: bd.company_name,
                    reference: "HP-#{bd.id}",
                    default_sales_ledger_account_id: '2ce906040ffc11e7bb3b065b8ec10ed1', #Ventas de mercaderías (70000000)
                    default_purchase_ledger_account_id: '2ce8db5c0ffc11e7bb3b065b8ec10ed1', #Compras de mercaderías (60000000)
                    tax_number: bd.vat_number.present? && bd.country && bd.country.in_eu? ? bd.country + bd.vat_number : nil,
                    credit_terms_and_conditions: '',
                    currency_id: 'EUR',
                    main_address: {
                        name: 'Default',
                        address_line_1: bd.address_line_1,
                        address_line_2: bd.address_line_2,
                        city: bd.city,
                        region: bd.state,
                        postal_code: bd.zip,
                        country_id: bd.country,
                    },
                    main_contact_person: {
                        name: bd.contact_name,
                        email: bd.contact_email
                    },
                }
            }
        )
    )
    bd.sage_one_contact_id = response['id']
    bd.save!
    response
  end

  def self.sales_invoices(page=1, items_per_page=20)
    call_api(
        "get",
        "accounts/v3/sales_invoices?page=#{page}&items_per_page=#{items_per_page}")
  end

  def self.sales_invoice(id)
    call_api(
        "get",
        "accounts/v3/sales_invoices/#{id}")
  end

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

  def expired?
    expires_at < DateTime.now
  end

  def renew_token!
    body_params = SageOne.token_request_body
    body_params << ["grant_type", "refresh_token"]
    body_params << ["refresh_token", self.refresh_token]

    save_token(body_params)
  end

  def self.config
    Rails.configuration.sageone
  end

  def self.get
    @singleton ||= SageOne.first_or_create
    if @singleton.expires_at < Time.now + 30.minutes
      @singleton.renew_token!
    end
    @singleton
  end

  def self.renew_token!
    so = SageOne.get
    so.renew_token!
    return so
  end

  def validate_single_row
    errors.add(:base, 'There can only be one row in SageOne') unless SageOne.count == 0 || SageOne.first == self
  end

  def self.token_request_body
    body_params = []
    body_params << ["client_id", SageOne.config[:client_id]]
    body_params << ["client_secret", SageOne.config[:client_secret]]
    body_params
  end

  def self.save_token(body_params)
    s = SageOne.first_or_create
    s.save_token(body_params)
  end

  def save_token(body_params)
    begin
      response = RestClient.post SageOne.config[:token_endpoint], URI.encode_www_form(body_params)
    rescue => e
      raise IOError, e.response.to_s
    end

    parsed = JSON.parse(response.to_str)

    self.access_token = parsed["access_token"]
    self.expires_at = Time.now + parsed["expires_in"].to_i
    self.refresh_token = parsed["refresh_token"]
    self.scopes = parsed["scopes"]
    self.requested_by_id = parsed["requested_by_id"]
    self.resource_owner_id = parsed["resource_owner_id"]
    self.save!
  end

  def put_or_post?(method)
    ["put", "post"].include? method
  end
end
