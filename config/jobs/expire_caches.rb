module Jobs
  class ExpireCaches
    @queue = :jobs
    
    def self.perform(options)
      hour = options.present? && options["hour"].present? ? options["hour"].to_i : 0  
      Jobs::say "Initiating expirecaches job (at #{hour})!"
      if Rails.configuration.action_controller.perform_caching
        kpis = Indicator.unscoped.due('0 day').merge(User.at_hour(hour))
        kpis.each { |indicator| 
          Jobs::say " KPI: #{indicator.name}"
          #expire_swept_caches_for(indicator)
          #Error: NoMethodError: undefined method `expire_swept_caches_for' for #<Jobs::ExpireCaches:0x007f2dd4f88e10>
          area = Area.unscoped.find(indicator.area_id)
          area.touch
          area.save!(validate: false)
        }
        tasks = Task.unscoped.due_today.merge(User.at_hour(hour))
        tasks.each { |task| 
          Jobs::say "Task: #{task.name}"
          #expire_swept_caches_for(task)
          area = Area.unscoped.find(task.area_id)
          area.touch
          area.save!(validate: false)
        }
      end
      Jobs::say "End expirecaches job!"
    end
  end
end
