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
    rescue => e
      raise IOError, e.response.to_s
    end
  end

  def self.exchange_code_for_token(code)
    body_params = token_request_body
    body_params << ["code", code]
    body_params << ["grant_type", "authorization_code"]
    body_params << ["redirect_uri", SageOne.config[:callback_url]]

    save_token(body_params)
  end


  def create_sales_invoice(subscription, amount)
    billing_detail = subscription.billing_detail
    response = SageOne.call_api(
        "post",
        "accounts/v3/sales_invoices",
        JSON.generate(
            {
                sales_invoice: {
                    contact_id: billing_detail.sage_one_contact_id,
                    date: Date.today,
                    due_date: Date.today,
                    main_address: {
                        address_line_1: billing_detail.address_line_1,
                        city: billing_detail.address_line_1,
                        region: billing_detail.state,
                        postal_code: billing_detail.zip,
                        country_id: billing_detail.country
                    },
                    invoice_lines: [
                        {
                            description: subscription.billing_description,
                            ledger_account_id: 'eb76db49279511e7bb3b065b8ec10ed1', #Ventas de mercaderías (70000000)
                            quantity: 1,
                            unit_price: amount,
                            discount_amount: 0,
                            tax_rate_id: billing_detail.country == 'ES' ? 'ES_STANDARD' : 'ES_NO_TAX' #EX_EXCEMPT, ES_LOWER_1, ES_LOWER_2
                        }
                    ]
                }
            }
        )
    )
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

  def renew_token!
    body_params = SageOne.token_request_body
    body_params << ["refresh_token", self.refresh_token]
    body_params << ["grant_type", "refresh_token"]

    SageOne.save_token(body_params)
  end

  def self.config
    Rails.configuration.sageone
  end

  private

  def self.get
    @singleton ||= SageOne.first_or_create
    if @singleton.expires_at < Time.now
      @singleton = SageOne.first_or_create
      if @singleton.expires_at < Time.now
        @singleton.renew_token!
      end
    end
    @singleton
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
    begin
      response = RestClient.post SageOne.config[:token_endpoint], URI.encode_www_form(body_params)
    rescue => e
      raise IOError, e.response.to_s
    end

    parsed = JSON.parse(response.to_str)
    s = SageOne.first_or_create
    s.access_token = parsed["access_token"]
    s.expires_at = Time.now + parsed["expires_in"].to_i
    s.refresh_token = parsed["refresh_token"]
    s.scopes = parsed["scopes"]
    s.requested_by_id = parsed["requested_by_id"]
    s.resource_owner_id = parsed["resource_owner_id"]
    s.save!
  end

  def put_or_post?(method)
    ["put", "post"].include? method
  end
end
