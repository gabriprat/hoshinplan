module Jobs
  class SetColors
    @queue = :jobs
    
    def self.perform(hour = 0)
      ret = ""
      begin
      ret += Jobs::say "Initiating setcolors job (at #{hour})!" + "\n"
      Hoshin.unscoped.where(color: nil).each { |h|
        ret += Jobs::say "Hoshin: " + h.name.to_s + "\n"
        h.update_attribute("color", h.defaultColor)
      }
      ret += Jobs::say "End setcolors job!" + "\n"
      rescue 
        ret += Jobs::say $!.inspect + "\n"
        ret += Jobs::say $@
      end
      return ret
    end
  end
end
