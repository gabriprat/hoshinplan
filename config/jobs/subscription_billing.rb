module Jobs
  class SubscriptionBilling

    @queue = :jobs

    def self.perform(options)
      ret = ""
      begin
        User.current_user = nil
        User.current_id = -1
        ret += Jobs::say "Initiating subscription billing job!" + "\n"
        subscriptions = SubscriptionStripe.unscoped.includes(:company)
                            .where("status = 'Active' and next_payment_at <= date_trunc('day',now()) and subscriptions.payment_error is null and paying_at is null and companies.payment_error is null")
                            .references(:company)

        subscriptions.each {|s|
          begin
            s.paying_at = Time.now
            s.save!(validate: false)
            ret += Jobs::say "Initiating a charge to company=#{s.company_id}" + "\n"
            amount = s.charge
            ret += Jobs::say "Charge done (#{s.amount_currency}#{amount})" + "\n"
            s.paying_at=nil
            s.next_payment_at = s.compute_next_payment_at
            s.last_payment_at = Time.now
            s.save!(validate: false)
            ret += Jobs::say "Subscription updated" + "\n"
          rescue => e
            msg = e.respond_to?(:json_body) ? JSON.pretty_generate(e.json_body) : e.message
            bt = Rails.backtrace_cleaner.clean(e.backtrace).join("\n") + "\n"
            text = "Payment error for subscription #{s.id}!\n" + msg + "\n" + bt
            UserCompanyMailer.admin_payment_error(s, text).deliver_later
            ret += Jobs::say "==== Error processing charge!!! \n #{msg}" + "\n" + bt
            s.paying_at=nil
            s.payment_error = msg + " \n " + bt
            s.save!(validate: false)
            ret += Jobs::say "==== Payment error stored" + "\n"
          end
        }
        ret += Jobs::say "End subscription billing job!" + "\n"
      rescue
        ret += Jobs::say $!.inspect + "\n"
        ret += Jobs::say $@.to_s
      end
      return ret
    end
  end
end
