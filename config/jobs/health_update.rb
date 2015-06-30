module Jobs
  class HealthUpdate
    @queue = :jobs
    
    def self.perform(hoshin_id=nil)
      Jobs::say "Initiating healthupdate job!"    
      if hoshin_id.nil?
        Hoshin.unscoped.all.each{|hoshin|
           perform_one(hoshin)
        }
      else
        begin
          hoshin = Hoshin.unscoped.find(hoshin_id)
          perform_one(hoshin)
        rescue ActiveRecord::RecordNotFound
          #Avoid errors when deleting hoshins
        end
      end
      Jobs::say "End healthupdate job!"
    end
    
    def self.perform_one(hoshin)
      begin
        hoshin.all_user_companies = nil
        uc_ids = UserCompany.unscoped.select(:user_id).where(:company_id => hoshin.company_id)
        users = User.unscoped.where(:id => uc_ids)
        if (users.length > 0)
          User.current_user = User.unscoped.where(:id => uc_ids).first
          User.current_id = User.current_user.id
          acting_user = User.current_user
        else
          Jobs::say "Hoshin with no users! #{hoshin.id} -- #{hoshin.name}"
          return 
        end
        hoshin.sync_health_update!(force=true)
        Jobs::say "Updated hoshin widh id=#{hoshin.id} (#{hoshin.name})"
      ensure
        User.current_user = nil
        User.current_id = nil
        acting_user = nil
      end
    end
  end
end
