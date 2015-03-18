module Jobs
  class SendReminders < Struct.new(:hour)  
    
    def perform
      self.hour ||= 7
      self.hour = self.hour.to_i
      @text = ll "Initiating send reminders job!"
      User.current_user = -1
      kpis = User.at_hour(hour).includes(:indicators, {:indicators => :hoshin}, {:indicators => :company}).joins(:indicators).merge(Indicator.unscoped.due('5 day')).order("indicators.company_id, indicators.hoshin_id")
      tasks = User.at_hour(hour).includes(:tasks, {:tasks => :hoshin}, {:tasks => :company}).joins(:tasks).merge(Task.unscoped.due('5 day')).order("tasks.company_id, tasks.hoshin_id")
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
          I18n.locale = user.language.to_s
          @text +=  ll " ==== User: #{user.email_address}" 
          UserCompanyMailer.reminder(user, com[:kpis], com[:tasks]).deliver if user.email_address = 'gabriel.prat@infojobs.net'
        ensure
          I18n.locale = old_locale
        end
      }
      @text += ll "End send reminders job!"
    end
  end
end