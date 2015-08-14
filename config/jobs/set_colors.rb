module Jobs
  class SetColors
    @queue = :jobs
    
    def self.perform(hour = 0)
      begin
      Jobs::say "Initiating setcolors job (at #{hour})!"
      Hoshin.unscoped.where(color: nil).each { |h|
        Jobs::say "Hoshin: " + h.name.to_s
        h.update_attribute("color", h.defaultColor)
      }
      Jobs::say "End setcolors job!"
      rescue 
        Jobs::say $!.inspect
        Jobs::say $@
      end
    end
  end
end
