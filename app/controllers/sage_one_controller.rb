CUENTA_CORRIENTE_57200000 = "2cb8fed00ffc11e7bb3b065b8ec10ed1"

class SageOneController < ApplicationController

  hobo_controller

  def auth
    redirect_to SageOne.config[:auth_endpoint] + "/central?response_type=code&client_id=#{SageOne.config[:client_id]}&redirect_uri=#{SageOne.config[:callback_url]}"
  end

  def callback
    if params[:code].present?
      SageOne.exchange_code_for_token(params[:code])
    end
    render text: 'OK!'
  end

  def sales_invoices
    render json: SageOne.sales_invoices(params[:page], params[:items_per_page])
  end

  def sales_invoice
    render json: SageOne.sales_invoice(params[:id])
  end

  def contacts
    render json: SageOne.contacts(params[:page], params[:items_per_page], params[:search], params[:email])
  end

  def contact
    render json: SageOne.contact(params[:id])
  end

  def create_contact
    render json: SageOne.create_contact
  end

  def create_invoices
    render json: SageOne.create_invoices
  end

  def send_invoice
    UserCompanyMailer.invoice(params[:id]).deliver_later
    render text: 'OK!'
  end

  def ledger_accounts
    render json: SageOne.ledger_accounts(params[:page], params[:items_per_page])
  end

  def tax_rates
    render json: SageOne.tax_rates(params[:page], params[:items_per_page])
  end

  def renew_token
    render json: SageOne.renew_token!
  end

  def cb_customer
    edit = params[:event_type] == 'customer_changed'
    customer = params[:content][:customer]
    billing_address = customer[:billing_address]
    endpoint = "accounts/v3/contacts"
    sage_id = ChargebeeCustomer.find_by(chargebee_id: customer[:id])&.sage_id
    if edit and sage_id
      endpoint = "#{endpoint}/#{sage_id}"
    else
      edit = false
    end
    method = edit ? 'put' : 'post'
    country = ISO3166::Country.new(customer[:billing_address][:country])
    response = SageOne.call_api(
        method,
        endpoint,
        JSON.generate(
            {
                contact: {
                    contact_type_ids: [
                        'CUSTOMER'
                    ],
                    product_sales_price_type_id: '2cf1d2fa0ffc11e7bb3b065b8ec10ed1', #Precio de venta
                    name: billing_address[:company] || billing_address[:first_name] + ' ' + billing_address[:last_name],
                    default_sales_ledger_account_id: '2ce906040ffc11e7bb3b065b8ec10ed1', #Ventas de mercaderías (70000000)
                    default_purchase_ledger_account_id: '2ce8db5c0ffc11e7bb3b065b8ec10ed1', #Compras de mercaderías (60000000)
                    tax_number: customer[:vat_number_status] == 'valid' && country && country.in_eu? ? country.alpha2 + customer[:vat_number] : nil,
                    credit_terms_and_conditions: '',
                    currency_id: 'EUR',
                    main_address: {
                        name: billing_address[:company] || "#{billing_address[:first_name]} #{billing_address[:last_name]}",
                        address_line_1: billing_address[:line1],
                        address_line_2: billing_address[:line2],
                        city: billing_address[:city],
                        region: billing_address[:state],
                        postal_code: billing_address[:zip],
                        country_id: billing_address[:country],
                    },
                    main_contact_person: {
                        name: "#{billing_address[:first_name]} #{billing_address[:last_name]}",
                        email: customer[:email],
                    },
                }
            }
        )
    )
    unless edit
      ChargebeeCustomer.create(chargebee_id: customer[:id], sage_id: response['id'])
    end
    response
  end

  def cb_invoice
    tax_rate_ids = {
        0.0 => 'ES_EXEMPT',
        4.0 => 'ES_LOWER_1',
        10.0 => 'ES_LOWER_2',
        21.0 => 'ES_STANDARD'
    }
    invoice = params[:content][:invoice]
    country = ISO3166::Country.new(invoice[:billing_address][:country])
    response = SageOne.sales_invoices(1, 1, invoice[:id])
    method = response['$total'] == 0 ? 'post' : 'put'
    endpoint = "accounts/v3/sales_invoices"
    if response['$total'] > 0
      invoice_id = response['$items'][0]['id']
      endpoint += "/#{invoice_id}"
    end
    puts endpoint + ' ' + method
    sage_id = ChargebeeCustomer.find_by(chargebee_id: invoice[:customer_id])&.sage_id
    billing_address = invoice[:billing_address]
    prefix, invoice_number = invoice[:id].split('-')
    invoice_lines = invoice[:line_items].map {|line|
      tax_rate_id = tax_rate_ids[line[:tax_rate]] || 'ES_EXEMPT'
      if country.in_eu? && country.alpha2 != 'ES' && line[:tax_amount] > 0
        tax_rate_id = 'ES_STANDARD'
      end
      ret = {
          description: line[:description],
          ledger_account_id: '2ce906040ffc11e7bb3b065b8ec10ed1', #Ventas de mercaderías (70000000)
          quantity: line[:quantity],
          unit_price: line[:unit_amount] / 100,
          net_amount: line[:amount] / 100,
          discount_amount: 0,
          tax_rate_id: tax_rate_id
      }
      if country.in_eu? && country.alpha2 != 'ES'
        ret['eu_goods_services_type_id'] = 'SERVICES'
      end
      ret
    }
    response = SageOne.call_api(
        method,
        endpoint,
        JSON.generate(
            {
                sales_invoice: {
                    status_id: invoice[:status] == 'paid' ? 'PAID' : 'UNPAID',
                    reference: invoice[:id],
                    contact_id: sage_id,
                    date: Time.at(invoice[:date]),
                    invoice_number_prefix: "#{prefix}-",
                    invoice_number: invoice_number,
                    invoice_lines: invoice_lines,
                    net_amount: invoice[:taxable_amount],
                    tax_amount: invoice[:tax] / 100,
                    total_amount: invoice[:total] / 100,
                    main_address: {
                        name: billing_address[:company],
                        address_line_1: billing_address[:line1],
                        address_line_2: billing_address[:line2],
                        city: billing_address[:city],
                        region: billing_address[:state],
                        postal_code: billing_address[:zip],
                        country_id: billing_address[:country],
                    },
                }
            }
        )
    )
    shouldCreatePayment = invoice[:status] == 'paid' && response['status']['id'] == 'UNPAID'
    if (shouldCreatePayment)
      SageOne.call_api(
          'post',
          "accounts/v3/contact_payments",
          JSON.generate(
              {
                  contact_payment: {
                      transaction_type_id: "CUSTOMER_RECEIPT",
                      payment_method_id: "CREDIT_DEBIT",
                      contact_id: response['contact']['id'],
                      bank_account_id: CUENTA_CORRIENTE_57200000,
                      date: Time.at(invoice[:paid_at]),
                      total_amount: invoice[:amount_paid].to_i / 100,
                      allocated_artefacts: [
                          {
                              artefact_id: response['id'],
                              amount: invoice[:amount_paid].to_i / 100
                          }
                      ]
                  }
              }
          )
      )
      response = SageOne.sales_invoice(response[:id])
    end
  end


  def cb_webhook
    if params[:event_type] == 'customer_changed' || params[:event_type] == 'customer_created'
      response = cb_customer
    elsif params[:event_type] == 'invoice_updated' || params[:event_type] == 'invoice_generated'
      response = cb_invoice
    end
    render json: response
  end

end
