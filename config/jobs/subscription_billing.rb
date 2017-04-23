module Jobs
  class SubscriptionBilling
    @queue = :jobs

    def self.perform(options)
      hour = options.present? && options[:hour].present? ? options[:hour].to_i : 8
      ret = ""
      begin
        User.current_user = nil
        User.current_id = -1
        ret += Jobs::say "Initiating subscription billing job (at #{hour})!" + "\n"
        subscriptions = SubscriptionStripe.unscoped
                            .where("status = 'Active' and next_payment_at = date_trunc('day',now())")

        subscriptions.each {|s|
          begin
            s.next_payment_at = s.compute_next_payment_at
            s.paying_at = Time.now
            s.save
            Jobs::say "Initiating a charge to company=#{s.company_id}" + "\n"
            amount = s.charge
            Jobs::say "Charge done (#{s.amount_currency}#{amount})" + "\n"
            s.paying_at=nil
            s.last_payment_at = Time.now
            s.save
            Jobs::say "Subscription updated" + "\n"
          rescue => e
            text = "Payment error for subscription #{s.id}!" + e.message + e.backtrace.join("\n")
            UserCompanyMailer.admin_payment_error(s, text).deliver_later
            Jobs::say "==== Error processing charge!!! #{e.message}" + "\n"
            s.payment_error = e.message.to_s + " ==== " + e.backtrace.to_s
            s.save
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
