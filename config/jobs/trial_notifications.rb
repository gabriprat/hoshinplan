module Jobs
  class TrialNotifications
    @queue = :jobs

    def self.perform(options)
      hour = options.present? && options["hour"].present? ? options["hour"].to_i : 8
      days = options.present? && options["days"].present? ? options["days"].to_i : 3
      ret = ''
      begin
        ret += Jobs::say "Initiating trial notifications job (at #{hour})!" + "\n"
        User.current_id = -1
        users = nil
        if (days > 0)
          users = User.distinct.at_hour(hour).joins(:my_companies)
                      .where("companies.subscriptions_count = 0" +
                                 " and unlimited = false" +
                                 " and users.trial_ends_at between ? and ?" +
                                 " and trial_ending_email is null",
                             Date.today + 1.days, Date.today + days.days)
        else
          users = User.distinct.at_hour(hour).joins(:my_companies)
                      .where("companies.subscriptions_count = 0" +
                                 " and unlimited = false" +
                                 " and users.trial_ends_at between ? and ?" +
                                 " and trial_ended_email is null",
                             Date.today - 30.days, Date.today)
        end

        Jobs::say users.to_sql
        users.each {|u|
          begin
            ret += Jobs::say "Sending email to user=#{u.email_address} (id: #{u.id})" + "\n"
            if (days > 0)
             u.trial_ending_email = Time.now
            else
              u.trial_ended_email = Time.now
            end
            c = u.my_companies.first
            UserCompanyMailer.trial_notifications(u, c, days).deliver_later
            u.save
            Mp.log_event( (days > 0 ? "Trial -3d email" : "Trial expired email"),
                          u, '', {company_id: c.id, company_name: c.name} )
          rescue => e
            Nr.track_exception e
            ret += Jobs::say "==== Error sending email #{e.message}" + "\n"
          end
        }
        ret += Jobs::say "End trial notifications  job!" + "\n"
      rescue
        Nr.track_exception $!
        ret += Jobs::say $!.inspect + "\n"
        ret += Jobs::say $@.to_s
      end
      return ret
    end
  end
end
