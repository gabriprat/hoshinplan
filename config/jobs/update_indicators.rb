module Jobs
  class UpdateIndicators
    
    def self.do_it
      User.current_user = User.administrator.first
      @text = ll " Initiating updateindicators job!"
      ihs = IndicatorHistory.joins(:indicator).includes({:indicator => :responsible}, {:indicator => :hoshin})
        .where("day = #{User::TODAY_SQL}  and (
            indicator_histories.goal != indicators.goal
            or indicators.goal is null and indicator_histories.goal is not null 
            or indicator_histories.value != indicators.value
            or indicators.value is null and indicator_histories.value is not null 
            or last_update != day
            or last_update is null
            )").references(:indicator)
      ihs.each { |ih| 
        ind = ih.indicator
        line = ind.id.to_s + " " + (ind.name.nil? ? 'N/A' : ind.name)   + ": "
        if (!ih.goal.nil? && (ind.goal.nil? || ind.goal != ih.goal))
          line += "goal #{ind.goal} => #{ih.goal}"
          ind.goal = ih.goal
        end
        updated = false
        if (!ih.value.nil? && (ind.value.nil? || ind.value != ih.value))
          line += " value #{ind.value} => #{ih.value} last_update #{ind.last_update} => #{ih.day}"
          ind.value = ih.value
          updated = true
        end
        if (updated && (ind.last_update.nil? || ind.last_update < ih.day))
          line += " last_update #{ind.last_update} => #{ih.day}"
          ind.last_update = ih.day
        end
        @text += ll line
        ind.save!({:validate => false})
      }
      @text += ll "End update indicators job!"
    end
    
    def perform
      say("Hello!!!!!!!")
      say self.class.do_it
    end
    
    def say(text)
       Delayed::Worker.logger.add(Logger::DEBUG, text)
     end
  
  end
end