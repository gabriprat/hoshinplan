class SageActiveController < ApplicationController

  hobo_controller

  def auth
    redirect_to "#{Rails.configuration.sageactive[:auth_endpoint]}?response_type=code&client_id=#{Rails.configuration.sageactive[:client_id]}&scope=RDSA%20WDSA%20offline_access&redirect_uri=#{Rails.configuration.sageactive[:callback_url]}"
  end

  def callback
    if params[:code].present?
      exchange_code_for_token(params[:code])
    end
    render plain: 'OK!'
  end

  def create_invoice
    invoice_id = params[:invoice_id]
    invoice = Invoice.find(invoice_id)
    response = SageActive.create_sales_invoice(invoice)
    render json: response
  end

  def sales_invoices
    after = params[:after]
    first = params[:first] || 20
    response = SageActive.get_sales_invoices(first, after)
    render json: response
  end

  def sales_invoice
    id = params[:id]
    response = SageActive.get_sales_invoice(id)
    render json: response
  end

  def sales_invoice_by_operational_number
    operational_number = params[:operational_number]
    response = SageActive.get_sales_invoice_by_operational_number(operational_number)
    render json: response
  end

  def create_contact_for_billing_detail
    billing_detail_id = params[:billing_detail_id]
    billing_detail = BillingDetail.find(billing_detail_id)
    response = SageActive.create_contact(billing_detail)
    render json: response
  end

  def contacts
    after = params[:after]
    first = params[:first] || 20
    response = SageActive.get_contacts(first, after)
    render json: response
  end

  def contact
    id = params[:id]
    response = SageActive.get_contact(id)
    render json: response
  end

  def contact_by_document
    document_id = params[:documentId]
    response = SageActive.get_contact_by_document(document_id)
    render json: response
  end

  def ledger_accounts
    response = SageActive.get_ledger_accounts
    render json: response
  end

  def tax_rates
    response = SageActive.get_tax_rates
    render json: response
  end

  def renew_token
    SageActive.get.renew_token!
    render json: { message: 'Token renewed successfully' }
  end

  def send_invoice
    UserCompanyMailer.invoice(params[:id]).deliver_later
    render text: 'OK!'
  end

  def countries
    response = SageActive.get_countries(300)
    render json: response
  end

  def populate_countries
    response = SageActive.populate_countries
    render json: "ok!"
  end

  def cb_customer
    edit = params[:event_type] == 'customer_changed'
    customer = params[:content][:customer]
    billing_address = customer[:billing_address]

    # Find or create the BillingDetail
    billing_detail = BillingDetail.find_or_initialize_by(chargebee_id: customer[:id])
    billing_detail.assign_attributes(
      company_name: billing_address[:company],
      contact_name: "#{billing_address[:first_name]} #{billing_address[:last_name]}",
      contact_email: customer[:email],
      address_line_1: billing_address[:line1],
      address_line_2: billing_address[:line2],
      city: billing_address[:city],
      state: billing_address[:state],
      zip: billing_address[:zip],
      country: billing_address[:country],
      vat_number: customer[:vat_number],
    )
    billing_detail.save!

    Rails.logger.debug("Customer ID: #{customer[:id]}")
    Rails.logger.debug("BillingDetail chargebee_id before save: #{billing_detail.chargebee_id}")

    # Use the billing detail to create or update the contact
    if edit && billing_detail.sage_active_third_party_id
      # Update existing contact
      response = SageActive.update_contact(billing_detail.sage_active_third_party_id, billing_detail)
    else
      # Create new contact
      response = SageActive.create_contact(billing_detail)
      billing_detail.sage_active_third_party_id = response['id']
      billing_detail.save!
    end
    response
  end

  def cb_webhook
    if params[:event_type] == 'customer_changed' || params[:event_type] == 'customer_created'
      response = cb_customer
    elsif params[:event_type] == 'invoice_updated' || params[:event_type] == 'invoice_generated'
      response = cb_invoice
    end
    render json: response
  end

  def cb_invoice
    invoice_params = params[:content][:invoice]
    paid = invoice_params[:status] == 'paid'

    return "unpaid" unless paid

    # Retrieve the billing detail and customer ID
    billing_detail = BillingDetail.unscoped.find_by(chargebee_id: invoice_params[:customer_id])

    unless billing_detail&.sage_active_third_party_id
      raise "Sage Active customer not found for chargebee customer: #{invoice_params[:customer_id]}"
    end

    invoice = Invoice.unscoped.find_or_initialize_by(sage_active_operational_number: invoice_params[:id])
    invoice.assign_attributes(
      billing_detail_id: billing_detail.id,
      description: invoice_params[:line_items][0][:description],
      net_amount: invoice_params[:sub_total] / 100,
      tax_tpc: invoice_params[:tax] / 100,
      total_amount: invoice_params[:total] / 100
    )
    invoice.save!

    # Call the create_sales_invoice method
    response = SageActive.get_sales_invoice_by_operational_number(invoice_params[:id])
    if response
      invoice.sage_active_invoice_id = response['id']
      invoice.sage_active_operational_number = invoice_params[:id]
      invoice.save!
    else
      response = SageActive.create_sales_invoice(invoice)
      invoice.sage_active_invoice_id = response.dig('data', 'createSalesInvoice', 'id')
      invoice.sage_active_operational_number = invoice_params[:id]
      invoice.save!
      response = SageActive.get_sales_invoice(invoice.sage_active_invoice_id)
    end

    if response['status'] == 'Pending'
      response = SageActive.close_invoice(invoice)
      response = SageActive.get_sales_invoice(invoice.sage_active_invoice_id)
    end
    if response['status'] == 'Closed'
      response = SageActive.post_invoice(invoice)
      response = SageActive.get_sales_invoice(invoice.sage_active_invoice_id)
    end
    if response['status'] == 'Posted'
      response = SageActive.pay_sales_invoice(invoice)
    end
  end

  private

  def exchange_code_for_token(code)
    url = Rails.configuration.sageactive[:token_endpoint]
    payload = {
      grant_type: 'authorization_code',
      code: code,
      redirect_uri: Rails.configuration.sageactive[:callback_url],
      client_id: Rails.configuration.sageactive[:client_id],
      client_secret: Rails.configuration.sageactive[:client_secret]
    }
    headers = { "Content-Type" => "application/x-www-form-urlencoded" }

    response = RestClient.post(url, payload, headers)
    token_data = JSON.parse(response.body)
    Rails.logger.info("Token data: #{token_data}")
    sage_active = SageActive.first_or_create
    sage_active.access_token = token_data['access_token']
    sage_active.scopes = token_data['scope']
    sage_active.refresh_token = token_data['refresh_token']
    sage_active.expires_at = Time.now + token_data['expires_in'].to_i
    sage_active.save!
  rescue RestClient::ExceptionWithResponse => e
    raise IOError, "Failed to exchange code for token: #{e.response}"
  end

  def generate_contact_data(customer)
    billing_address = customer[:billing_address]
    country = ISO3166::Country.new(billing_address[:country])

    {
      "code" => "HP#{customer[:id]}",
      "documentId" => customer[:vat_number],
      "vatNumber" => customer[:vat_number_status] == 'valid' && country&.in_eu? ? "#{country.alpha2}#{customer[:vat_number]}" : customer[:vat_number],
      "socialName" => billing_address[:company] || "#{billing_address[:first_name]} #{billing_address[:last_name]}",
      "addresses" => [{
        "firstLine" => billing_address[:line1],
        "secondLine" => billing_address[:line2],
        "city" => billing_address[:city],
        "province" => billing_address[:state],
        "zipCode" => billing_address[:zip],
        "countryIsoCodeAlpha2" => billing_address[:country]
      }],
      "contacts" => [{
        "isDefault" => true,
        "name" => billing_address[:first_name],
        "surname" => billing_address[:last_name],
        "emails" => [{
          "isDefault" => true,
          "emailAddress" => customer[:email],
          "usage" => "EMPTY"
        }]
      }]
    }
  end
end