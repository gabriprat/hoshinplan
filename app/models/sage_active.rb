require 'rest_client'
require 'json'

class SageActive < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    access_token :string
    expires_at :datetime
    refresh_token :string
    scopes :string
    timestamps
  end
  attr_accessible :access_token, :expires_at, :refresh_token, :scopes
  validate :validate_single_row

  before_create do
    self.expires_at ||= Time.now
  end

  def self.call_api(query, variables = {})
    url = "#{Rails.configuration.sageactive[:base_endpoint]}/graphql"
    headers = {
      "Authorization" => "Bearer #{get.access_token}",
      "x-api-key" => Rails.configuration.sageactive[:subscription_key],
      'X-TenantId' => Rails.configuration.sageactive[:tenant_id],
      'X-OrganizationId' => Rails.configuration.sageactive[:organization_id],
      "Content-Type" => "application/json"
    }
    payload = { query: query, variables: variables }.to_json

    begin
      response = RestClient.post(url, payload, headers)
      ret = JSON.parse(response.body)
      raise IOError, ret['errors'][0]['message'] if ret['errors']
      ret
    rescue RestClient::ExceptionWithResponse => e
      raise IOError, "#{e}: #{e.response}", e.backtrace
    end
  end

  def self.get
    @singleton ||= SageActive.first_or_create
    if @singleton.refresh_token && @singleton.expires_at < Time.now + 30.minutes
      @singleton = SageActive.first_or_create
      if @singleton.refresh_token && @singleton.expires_at < Time.now + 30.minutes
        @singleton.renew_token!
      end
    end
    @singleton
  end

  def self.access_token
    get.access_token
  end

  def renew_token!
    url = Rails.configuration.sageactive[:token_endpoint]
    payload = {
      grant_type: 'refresh_token',
      client_id: Rails.configuration.sageactive[:client_id],
      client_secret: Rails.configuration.sageactive[:client_secret],
      refresh_token: self.refresh_token
    }
    headers = { "Content-Type" => "application/x-www-form-urlencoded" }

    Rails.logger.info("Refreshing token #{payload} #{headers}")

    response = RestClient.post(url, payload, headers)
    token_data = JSON.parse(response.body)
    self.access_token = token_data['access_token']
    self.refresh_token = token_data['refresh_token']
    self.expires_at = Time.now + token_data['expires_in'].to_i
    self.save!
    self.access_token
  rescue RestClient::ExceptionWithResponse => e
    Rails.logger.error("Failed to refresh token: #{e.response}")
    raise IOError, "Failed to refresh token: #{e.response}"
  end

  def validate_single_row
    errors.add(:base, 'There can only be one row in SageActive') unless SageActive.count == 0 || SageActive.first == self
  end

  def self.create_sales_invoice(invoice)
    if invoice.billing_detail_id.present?
      billing_detail = BillingDetail.unscoped.find(invoice.billing_detail_id)
    elsif invoice.subscription_id.present?
      subscription = Subscription.unscoped.find(invoice.subscription_id)
      billing_detail = BillingDetail.unscoped.find(subscription.billing_detail_id)
    end

    unless billing_detail.sage_active_third_party_id
      customer = self.get_contact_by_document(billing_detail.vat_number)
      if customer.blank?
        self.create_contact(billing_detail)
      else
        billing_detail.sage_active_third_party_id = customer['id']
      end
    end

    query = <<-GRAPHQL
      mutation($input: SalesInvoiceCreateGLDtoInput!) {
        createSalesInvoice(input: $input) {
          id
        }
      }
    GRAPHQL

    invoice_data = {
      customerId: billing_detail.sage_active_third_party_id,
      lines: [
        {
          productCode: invoice.subscription_id.present? ? 'HOSHINPLAN' : 'PROMOTERNINJA',
          productName: invoice.description,
          totalQuantity: 1,
          unitPrice: invoice.net_amount.to_f,
        }
      ]
    }

    if invoice.sage_active_operational_number.present?
      invoice_data[:operationalNumber] = invoice.sage_active_operational_number
    else
      invoice_data[:operationalNumberPresetTextId] = "19cde8b4-8479-4eb6-a75b-4710b28af08b"
    end

    variables = { input: invoice_data }
    call_api(query, variables)
  end

  def self.get_invoice_open_items(invoice)
    query = <<-GRAPHQL
      query($Id: UUID!) {
        salesInvoiceOpenItems(
          order: {dueDate:ASC}
          where : {salesInvoice:{ id : { eq : $Id }}}
        ) {
          edges {
            node {
              salesInvoice {
                firstDueDate
                documentDate
                operationalNumber
                status
                totalLiquid
                customer {
                  id
                  code
                  socialName
                }
              }
              id
              status
              amount
              dueDate
              paidAmountAccumulated
              paymentMean {
                description
              }
            }
          }
        }
      }
    GRAPHQL

    variables = { Id: invoice.sage_active_invoice_id }
    data = call_api(query, variables)
    nodes = data.dig('data', 'salesInvoiceOpenItems', 'edges')
    nodes.map { |node| node['node'] }
  end

  def self.close_invoice(invoice)
    query = <<-GRAPHQL
      mutation($input: CloseSalesInvoiceGLDtoInput!) {
        closeSalesInvoice(input: $input) {
          id
          operationalNumber
        }
      }
    GRAPHQL

    variables = { input: {
      salesInvoiceId: invoice.sage_active_invoice_id,
    } }
    call_api(query, variables)
  end

  def self.post_invoice(invoice)
    query = <<-GRAPHQL
      mutation($input: PostSalesInvoiceGLDtoInput!) {
        postSalesInvoice(input: $input) {
          accountingEntryId
          accountingEntryNumber
        }
      }
    GRAPHQL

    variables = { input: {
      salesInvoiceId: invoice.sage_active_invoice_id,
      accountingEntryDescription: "Sales Invoice validation",
      journalTypeId: "16ceb06e-13b7-4360-9423-fe91eb329216",
    } }
    call_api(query, variables)
  end

  def self.pay_sales_invoice(invoice)
    open_items = get_invoice_open_items(invoice)

    query = <<-GRAPHQL
      mutation($input: SalesOpenItemSettlementGLDtoInput!) {
        salesOpenItemSettlement(input: $input) {
          accountingEntryId
          accountingEntryNumber
        }
      }
    GRAPHQL

    variables = { input: {
      entryDate: invoice.created_at.strftime('%Y-%m-%d'),
      description: "Full settlement of Invoice #{invoice.id}",
      documentNumber: invoice.id,
      paymentMethodId: '19cde8b4-69e8-4eb6-a75b-4710b28af08b',
      thirdPartyId: invoice.billing_detail.sage_active_third_party_id,
      salesOpenItemLinkagePaidAmounts: open_items.map { |item| {
        openItemId: item['id'],
        paidAmount: item['amount'],
      } }
    } }
    call_api(query, variables)
  end

  # Method to retrieve sales invoices
  def self.get_sales_invoices(first = 20, after)
    query = <<-GRAPHQL
      query($first: Int!#{', $after: String!' if after.present?}) {
        salesInvoices(first: $first#{', after: $after' if after.present?}, order: { operationalNumber: DESC }) {
          edges {
            node {
              ...InvoiceFields
            }
          }
          totalCount
          pageInfo {
            startCursor
            endCursor
            hasNextPage
            hasPreviousPage
          }
        }
      }
      #{INVOICE_FIELDS_FRAGMENT}
    GRAPHQL

    variables = { first: first.to_i }
    variables[:after] = after.to_s if after.present?

    response = call_api(query, variables)
    data = response['data']['salesInvoices']
    {
      documents: data['edges'].map { |edge| edge['node'] },
      totalCount: data['totalCount'],
      pageInfo: data['pageInfo']
    }
  end

  def self.get_sales_invoice(id)
    invoice_query(id: id)
  end

  def self.get_sales_invoice_by_operational_number(operational_number)
    invoice_query(operationalNumber: operational_number)
  end

  # Method to create a contact
  def self.create_contact(billing_detail)
    query = <<-GRAPHQL
      mutation($values: CustomerCreateGLDtoInput!) {
        createCustomer(input: $values) {
          id
          code
        }
      }
    GRAPHQL

    variables = { values: generate_contact_data(billing_detail) }
    data = call_api(query, variables)
    data['data']['createCustomer']
  end

  def self.update_contact(id, billing_detail)
    existingCustomer = get_contact(id)
    query = <<-GRAPHQL
      mutation($values: CustomerUpdateGLDtoInput!) {
        updateCustomer(input: $values) {
          id
        }
      }
    GRAPHQL

    values = generate_contact_data(billing_detail)
    apply_requested_actions(existingCustomer, values)
    call_api(query, { values: values })
  end

  # Method to retrieve contacts
  def self.get_contacts(first = 20, after)
    query = <<-GRAPHQL
      query($first: Int!#{', $after: String!' if after.present?}) {
        customers(first: $first#{', after: $after' if after.present?}, order: { code: DESC }) {
          edges {
            node {
              ...CustomerFields
            }
          }
          totalCount
          pageInfo {
            startCursor
            endCursor
            hasNextPage
            hasPreviousPage
          }
        }
      }
      #{CUSTOMER_FIELDS_FRAGMENT}
    GRAPHQL

    variables = { first: first.to_i }
    variables[:after] = after.to_s if after.present?

    response = call_api(query, variables)
    data = response['data']['customers']
    {
      documents: data['edges'].map { |edge| edge['node'] },
      totalCount: data['totalCount'],
      pageInfo: data['pageInfo']
    }
  end

  def self.get_contact(id)
    customer_query(id: id)
  end

  def self.get_contact_by_document(document_id)
    customer_query(documentId: document_id)
  end

  def self.get_countries(first = 20, after = nil)
    query = <<-GRAPHQL
      query($first: Int!#{', $after: String!' if after.present?}) {
        countries(first: $first#{', after: $after' if after.present?}, order: [{isoCodeAlpha2: ASC}]) {
          edges {
            node {
              ...CountryProps
            }
          }
          totalCount
          pageInfo {
            startCursor
            endCursor
            hasPreviousPage
            hasNextPage
          }
        }
      }
      #{COUNTRY_PROPS_FRAGMENT}
    GRAPHQL

    variables = { first: first.to_i }
    variables[:after] = after.to_s if after.present?

    response = call_api(query, variables)
    data = response['data']['countries']
    {
      countries: data['edges'].map { |edge| edge['node'] },
      totalCount: data['totalCount'],
      pageInfo: data['pageInfo']
    }
  end

  def self.populate_countries
    after = nil
    loop do
      response = get_countries(300, after)
      countries = response[:countries]
      after = response[:pageInfo]['endCursor']
      break if countries.empty?

      countries.each do |country|
        SageActiveCountry.find_or_create_by(id: country['id']) do |c|
          c.name = country['name']
          c.iso_code_alpha2 = country['isoCodeAlpha2']
          c.iso_code_alpha3 = country['isoCodeAlpha3']
          c.iso_number = country['isoNumber']
          c.legislation_country_code = country['legislationCountryCode']
          c.vies_code = country['viesCode']
          c.creationDate = country['creationDate']
          c.modificationDate = country['modificationDate']
        end
      end

      break unless response[:pageInfo]['hasNextPage']
    end
  end

  private

  CUSTOMER_FIELDS_FRAGMENT = <<-'GRAPHQL'
    fragment CustomerFields on Customer {
      id   
      socialName
      tradeName
      code
      documentId
      documentTypeId
      countryAcronym
      addresses {
        id
        firstLine
        secondLine
        city
        zipCode
        countryId
        countryName
        countryIsoCodeAlpha2
        name
        isDeliveryAddress
        isDefaultDeliveryAddress
      }
      contacts {
        id
        isDefault
        courtesy
        name
        surname
        emails {
          id
          emailAddress
          usage
        }
        phones {
          id
          number
          type
        }
        socialMedias {
          id
          link
          name
        }
        isDefault
      }
      paymentTermLines {
        id
        day
        condition
        type
        value
        payDays
        order
      }
      defaultAccountingAccountId
    }
  GRAPHQL

  def self.customer_query(conditions = {})
    where_clauses = conditions.map { |key, _| "#{key}: { eq: $#{key} }" }.join(', ')
    variable_definitions = conditions.keys.map { |key| "$#{key}: #{graphql_type(key)}" }.join(', ')

    query = <<-GRAPHQL
      query(#{variable_definitions}) {
        customers(where: { #{where_clauses} }) {
          edges {
            node {
              ...CustomerFields
            }
          }
        }
      }
      #{CUSTOMER_FIELDS_FRAGMENT}
    GRAPHQL

    response = call_api(query, conditions)
    edges = response.dig('data', 'customers', 'edges')
    edges.present? ? edges.first['node'] : nil
  end

  def self.graphql_type(key)
    case key
    when :id
      'UUID'
    else
      'String' # Default type, adjust as needed
    end
  end

  def self.get_ledger_accounts
    query = <<-GRAPHQL
      query {
        ledgerAccounts {
          edges {
            node {
              id
              name
            }
          }
        }
      }
    GRAPHQL

    call_api(query)
  end

  def self.get_tax_rates
    query = <<-GRAPHQL
      query {
        taxRates {
          edges {
            node {
              id
              name
              rate
            }
          }
        }
      }
    GRAPHQL

    call_api(query)
  end

  INVOICE_FIELDS_FRAGMENT = <<-'GRAPHQL'
    fragment InvoiceFields on SalesInvoice {
      firstDueDate
      id
      socialName
      operationalNumber
      salesOrderNumber
      creationDate
      customerId
      documentDate
      status
      totalNet
      discount
      lines {
        productCode
        productId
        productName
        totalQuantity
        unitPrice
        firstDiscount
        totalNet
      }
      openItems {
        status
        amount
        paidAmountAccumulated
        paymentMean {
          description
        }
      }
    }
  GRAPHQL

  def self.invoice_query(conditions = {})
    where_clauses = conditions.map { |key, _| "#{key}: { eq: $#{key} }" }.join(', ')
    variable_definitions = conditions.keys.map { |key| "$#{key}: #{graphql_type(key)}" }.join(', ')

    query = <<-GRAPHQL
      query(#{variable_definitions}) {
        salesInvoices(where: { #{where_clauses} }) {
          edges {
            node {
              ...InvoiceFields
            }
          }
        }
      }
      #{INVOICE_FIELDS_FRAGMENT}
    GRAPHQL

    response = call_api(query, conditions)
    edges = response.dig('data', 'salesInvoices', 'edges')
    edges.present? ? edges.first['node'] : nil
  end

  def self.generate_contact_data(billing_detail)
    address_line_1, address_line_2 = split_address(billing_detail.address_line_1, billing_detail.address_line_2)

    contact_data = {
      "code" => "HP#{billing_detail.id}",
      "documentId" => billing_detail.vat_number || "N/A-#{billing_detail.id}",
      "vatNumber" => billing_detail.eu? ? "#{billing_detail.country.alpha2}#{billing_detail.vat_number}" : '',
      "socialName" => billing_detail.company_name,
      "addresses" => [{
                        "firstLine" => address_line_1,
                        "secondLine" => address_line_2,
                        "city" => billing_detail.city,
                        "province" => billing_detail.state,
                        "zipCode" => billing_detail.zip,
                        "countryIsoCodeAlpha2" => billing_detail.country.alpha2
                      }],
      "contacts" => [{
                       "isDefault" => true,
                       "name" => billing_detail.contact_name.split.first,
                       "surname" => billing_detail.contact_name.split.last,
                       "emails" => [{
                                      "isDefault" => true,
                                      "emailAddress" => billing_detail.contact_email,
                                      "usage" => 'EMPTY'
                                    }]
                     }]
    }

    contact_data
  end

  def self.split_address(line1, line2)
    if line1.length > 35
      # Try to split at a space, hyphen, comma, colon, dot, or semicolon within the first 35 characters
      split_index = line1.rindex(/[\s\-,:.;]/, 35) || 35
      first_line = line1[0...split_index]
      second_line = line1[split_index..line1.length - 1].strip + " " + line2
    else
      first_line = line1
      second_line = line2 || ""
    end

    # Ensure the second line is within 35 characters
    second_line = second_line.strip[0...35] if second_line.length > 35

    [first_line, second_line]
  end

  COUNTRY_PROPS_FRAGMENT = <<-'GRAPHQL'
    fragment CountryProps on Country {
      id
      name
      isoCodeAlpha2
      isoCodeAlpha3
      isoNumber
      creationDate
      legislationCode
      modificationDate
      viesCode
    }
  GRAPHQL

  def self.apply_requested_actions(existing, updated)
    if (existing.present? && updated.present?)
      updated['requestedAction'] = 'MODIFY'
      updated['id'] = existing['id']
      updated.each do |key, value|
        if value.is_a?(Array)
          existing_items = existing[key] || []
          updated_items = value

          # Mark existing items for deletion if not present in updated
          existing_items.each_with_index do |existing_item, index|
            unless updated_items[index]
              existing_item['requestedAction'] = 'DELETE'
              updated_items << existing_item
            end
          end

          # Mark updated items for creation or modification
          updated_items.each_with_index do |updated_item, index|
            if existing_item = existing_items[index]
              updated_item['requestedAction'] = 'MODIFY'
              # Recursively handle nested structures
              apply_requested_actions(existing_item, updated_item)
            else
              updated_item['requestedAction'] = 'CREATE'
            end
          end
        elsif value.is_a?(Hash)
          apply_requested_actions(existing[key] || {}, value)
        end
      end
    end
  end
end

class SageActiveCountry < ActiveRecord::Base
  attr_accessible :id, :name, :iso_code_alpha2, :iso_code_alpha3, :iso_number, :legislation_country_code, :vies_code, :creationDate, :modificationDate
end