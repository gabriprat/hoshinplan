desc "This task is called by the Heroku scheduler add-on"

task :expire_caches => :environment do
  puts Jobs::ExpireCaches.new.perform
end

task :health_update => :environment do
  puts Jobs::HealthUpdate.new.perform
end

task :send_reminders => :environment do
  puts Jobs::SendReminders.new.perform
end

task :update_indicators => :environment do
  puts Jobs::UpdateIndicators.new.perform
end

