class InvoicesController < ApplicationController

  hobo_model_controller

  auto_actions :show

  auto_actions_for :subscription, [:index]

  include RestController

  api :GET, '/invoices/:id', 'Get an invoice'
  def show
    self.this = find_instance
    @filename = "invoice-#{self.this.sage_one_invoice_id || self.this.sage_active_operational_number}.pdf"
    hobo_show
  end

  api :GET, '/subscriptions/:subscription_id/invoices', 'Get all invoices for a specific subscription'
  def index_for_subscription
    hobo_index_for :subscription
  end

end