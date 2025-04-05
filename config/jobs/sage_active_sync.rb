module Jobs
  class SageActiveSync
    @queue = :jobs

    def self.perform(options)
      ret = ''
      begin
        ret += Jobs::say "Initiating Sage Active sync job!" + "\n"
        # Example: Fetch invoices to sync
        invoices = Invoice.unscoped.where({ sage_active_invoice_id: nil })
        ret += Jobs::say "Executing SQL: #{invoices.to_sql}" + "\n"

        invoices.each do |invoice|
          begin
            resp = SageActive.create_sales_invoice(invoice)
            invoice.sage_active_invoice_id = resp['data']['createSalesInvoice']['id']
            invoice.save!(validate: false)
            resp = SageActive.get_sales_invoice(invoice.sage_active_invoice_id)
            if resp['status'] == 'Pending'
              SageActive.close_invoice(invoice)
              resp = SageActive.get_sales_invoice(invoice.sage_active_invoice_id)
            end
            if resp['status'] == 'Closed'
              SageActive.post_invoice(invoice)
              resp = SageActive.get_sales_invoice(invoice.sage_active_invoice_id)
            end
            if resp['status'] == 'Posted'
              SageActive.pay_sales_invoice(invoice)
            end
            ret += Jobs::say " ==== Sending invoice #{invoice.id}\n"
            UserCompanyMailer.invoice(invoice.id).deliver_later
          rescue => e
            text = "Error synchronizing invoice #{invoice.id}. Billing detail: #{invoice.billing_detail}.\n" + e.message + "\n" + e.backtrace.to_yaml + "\n"
            ret += Jobs::say text
            UserCompanyMailer.admin_sage_sync_error(invoice, text).deliver_later
          end
        end
        ret += Jobs::say "End Sage Active sync job!" + "\n"
      rescue => e
        ret += Jobs::say e.inspect + "\n"
        ret += Jobs::say e.backtrace.to_s
      end
      return ret
    end
  end
end 