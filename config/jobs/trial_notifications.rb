module Jobs
  class SubscriptionBilling
    @queue = :jobs

    def self.perform(options)
      hour = options.present? && options["hour"].present? ? options["hour"].to_i : 8
      ret = ""
      begin
        ret += Jobs::say "Initiating subscription billing job (at #{hour})!" + "\n"
        subscriptions = SubscriptionStripe.at_hour(hour)
                            .where("status = 'Active' and next_payment_at = #{User::TODAY_SQL}")

        subscriptions.each {|s|
          begin
            days_to_add = case s.billing_period
              when 'annual' then 1.year
              when 'monthly' then 1.month
              else raise TypeError, "Unknown billing period #{s.billing_period}"
            end
            s.next_payment_at = s.next_payment_at + days_to_add
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
            UserCompanyMailer.admin_payment_error(s, e).deliver_now
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
