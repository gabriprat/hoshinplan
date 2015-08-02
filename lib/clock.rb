require File.expand_path('../../config/boot',        __FILE__)
require File.expand_path('../../config/environment', __FILE__)

require File.expand_path('../../config/jobs/base_job.rb',        __FILE__)
Dir['config/jobs/*.rb'].each {|file| require File.expand_path('../../' + file, __FILE__)}
include Clockwork

every(1.hour, 'update_indicators', :at => '**:00') { Resque.enqueue Jobs::UpdateIndicators }
every(1.day, 'health_update', :at => '23:30') { Resque.enqueue Jobs::HealthUpdate }
every(1.hour, 'send_reminders', :at => '**:40') { Resque.enqueue Jobs::SendReminders }
every(1.hour, 'expire_cahces', :at => '**:20') { Resque.enqueue Jobs::ExpireCaches }
