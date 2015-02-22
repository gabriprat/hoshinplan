require File.expand_path('../../config/boot',        __FILE__)
require File.expand_path('../../config/environment', __FILE__)

require File.expand_path('../../config/jobs/base_job.rb',        __FILE__)
Dir['config/jobs/*.rb'].each {|file| require File.expand_path('../../' + file, __FILE__)}
include Clockwork

every(1.hour, 'update_indicators', :at => '**:01') { Delayed::Job.enqueue Jobs::UpdateIndicators.new }
every(1.day, 'health_update', :at => '00:05') { Delayed::Job.enqueue Jobs::HealthUpdate.new }
every(1.hour, 'send_reminders', :at => '**:10') { Delayed::Job.enqueue Jobs::SendReminders.new }
every(1.hour, 'expire_cahces', :at => '**:30') { Delayed::Job.enqueue Jobs::ExpireCaches.new }


#, :at => '08:00'
