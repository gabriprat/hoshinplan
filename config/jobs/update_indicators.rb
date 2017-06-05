module Jobs
  class UpdateIndicators
    @queue = :jobs

    def self.perform(options)
      ret = ''
      User.current_user = User.administrator.first
      ret += Jobs::say " Initiating updateindicators job!\n"
      ihs = IndicatorHistory.joins(:indicator).includes({:indicator => :responsible}, {:indicator => :hoshin})
        .where("day = #{User::TODAY_SQL}  and (
            indicator_histories.goal is not null and indicator_histories.goal != indicators.goal
            or indicators.goal is null and indicator_histories.goal is not null
            or indicator_histories.value is not null and indicator_histories.value != indicators.value
            or indicators.value is null and indicator_histories.value is not null
            or last_update != day or last_update is null
            )").references(:indicator)
      ihs.each { |ih|
        ind = ih.indicator
        line = ind.id.to_s + " " + (ind.name.nil? ? 'N/A' : ind.name)   + ": "
        if (!ih.goal.nil? && (ind.goal.nil? || ind.goal != ih.goal))
          line += "goal #{ind.goal} => #{ih.goal}"
          ind.goal = ih.goal
        end
        if !ih.value.nil? && (ind.value.nil? || ind.value != ih.value)
          line += " value #{ind.value} => #{ih.value} last_update #{ind.last_update} => #{ih.day}"
          ind.value = ih.value
        end
        if !ih.value.nil? && (ind.last_update.nil? || ind.last_update < ih.day)
          line += " last_update #{ind.last_update} => #{ih.day}"
          ind.last_update = ih.day
        end
        if ind.changed?
          ret += Jobs::say line + "\n"
          Company.current_company = ind.company
          ind.save!({:validate => false})
        end
      }
      ret += Jobs::say "End update indicators job!"
      ret
    end
  end
end