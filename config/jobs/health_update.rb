module Jobs
  class HealthUpdate < BaseJob
    def self.do_it
      @text = ll "Initiating healthupdate job!"    
      Hoshin.unscoped.all.each{|hoshin|
        hoshin.all_user_companies = nil
        uc_ids = UserCompany.unscoped.select(:user_id).where(:company_id => hoshin.company_id)
        users = User.unscoped.where(:id => uc_ids)
        if (users.length > 0)
          User.current_user = User.unscoped.where(:id => uc_ids).first
          User.current_id = User.current_user.id
          acting_user = User.current_user
        else
          User.current_user = nil
          User.current_id = nil
          acting_user = nil
          @text += ll "Hoshin with no users! #{hoshin.id} -- #{hoshin.name}"
          next
        end
        @text += ll "Updating hoshin #{hoshin.id} -- #{hoshin.name}"
        begin
          hoshin.health_update!
        rescue => e 
          @text += ll "Error!"  + e.inspect + e.backtrace.to_yaml + acting_user.to_yaml
        end
      }
      @text += ll "End healthupdate job!"
    end
  end
end
