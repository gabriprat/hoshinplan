module Jobs
  class ExpireCaches
    def perform
      @text = ll "Initiating expirecaches job!"
      if Rails.configuration.action_controller.perform_caching
        kpis = Indicator.unscoped.due('0 day').merge(User.at_hour(0))
        kpis.each { |indicator| 
          @text +=  ll " KPI: #{indicator.name}"
          #expire_swept_caches_for(indicator)
          #Error: NoMethodError: undefined method `expire_swept_caches_for' for #<Jobs::ExpireCaches:0x007f2dd4f88e10>
          indicator.area.touch
        }
        tasks = Task.unscoped.due_today.merge(User.at_hour(0))
        tasks.each { |task| 
          @text +=  ll "Task: #{task.name}"
          #expire_swept_caches_for(task)
          task.area.touch
        }
      end
      @text += ll "End expirecaches job!"
    end
  end
end
