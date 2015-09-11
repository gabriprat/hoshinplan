module Jobs
  class SendReminders
    @queue = :jobs 
    
    def self.perform(hour = 7)
      hour = hour.to_i
      Rails.logger.info "Initiating send reminders job (at #{hour})!"
      User.current_user = User.administrator.first
      User.current_id = User.current_user.id
      kpis = User.at_hour(hour).includes(:indicators, {:indicators => :hoshin}, {:indicators => :company}).joins(:indicators).merge(Hoshin.unscoped.active).merge(Indicator.unscoped.due('5 day')).order("indicators.company_id, indicators.hoshin_id")
      tasks = User.at_hour(hour).includes(:tasks, {:tasks => :hoshin}, {:tasks => :company}).joins(:tasks).merge(Hoshin.unscoped.active).merge(Task.unscoped.due('5 day')).order("tasks.company_id, tasks.hoshin_id")
      comb = {}
      kpis.each {|user|
        com = comb[user.id] || {:user => user}
        com[:kpis] = user.indicators
        comb[user.id] = com
      }
      tasks.each {|user|
        com = comb[user.id] || {:user => user}
        com[:tasks] = user.tasks
        comb[user.id] = com
      }
      comb.values.each { |com|
        user = com[:user]
        old_locale = I18n.locale
        begin
          I18n.locale = user.language.to_s unless user.language.to_s.blank?
          I18n.locale ||= I18n.default_locale
          Rails.logger.info " ==== User: #{user.email_address}" 
          UserCompanyMailer.reminder(user, com[:kpis], com[:tasks]).deliver 
        ensure
          I18n.locale = old_locale
        end
      }
      Rails.logger.info "End send reminders job!"
    end
  end
end