module Jobs
  class SageOneSync

    @queue = :jobs

    def self.perform(options)
      ret = ''
      so = SageOne.get
      begin
        ret += Jobs::say "Initiating sage one sync job!" + "\n"
        invoices = Invoice.unscoped.where({sage_one_invoice_id: nil})
        ret += Jobs::say "Executing SQL: #{invoices.to_sql}" + "\n"
        if so.expired?
          so.renew_token!
        end
        invoices.each do |invoice|
          begin
            resp = SageOne.create_sales_invoice invoice
            subscription = Subscription.unscoped.find(invoice.subscription_id)
            billing_detail = BillingDetail.unscoped.find(subscription.billing_detail_id)
            if billing_detail.vat_number.present? && billing_detail.vies_valid
              invoice.sage_one_invoice_id = resp['invoice_number']
              invoice.save!(validate: false)
              ret += Jobs::say " ==== Sending invoice #{invoice.id} + #{subscription.billing_description}\n"
              UserCompanyMailer.invoice(invoice).deliver_later
            end
          rescue
            ret += Jobs::say "Error synchronizing invoice #{invoice.id}\n" + $!.inspect + "\n" + $!.backtrace.to_yaml + "\n"
          end
        end
        ret += Jobs::say "End sage one sync job!" + "\n"
      rescue
        ret += Jobs::say $!.inspect + "\n"
        ret += Jobs::say $@.to_s
      end
      return ret
    end
  end
end
