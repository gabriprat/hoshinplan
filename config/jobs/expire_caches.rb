module Jobs
  class ExpireCaches < BaseJob
    def self.do_it
      @text = ll "Initiating expirecaches job!"
      if Rails.configuration.action_controller.perform_caching
        kpis = Indicator.unscoped.due('0 day').merge(User.at_hour(0))
        kpis.each { |indicator| 
          @text +=  ll " KPI: #{indicator.name}"
          #expire_swept_caches_for(indicator)
          #expire_swept_caches_for(indicator.area)
        }
        tasks = Task.unscoped.due_today.merge(User.at_hour(0))
        tasks.each { |task| 
          @text +=  ll "Task: #{task.name}"
          #expire_swept_caches_for(task)
          #expire_swept_caches_for(task.area)
        }
      end
      @text += ll "End expirecaches job!"
    end
  end
end
