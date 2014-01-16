require File.expand_path('../../config/boot',        __FILE__)
require File.expand_path('../../config/environment', __FILE__)
require File.expand_path('../../config/jobs/reminders', __FILE__)
include Clockwork

every(1.day, 'reminders') { Delayed::Job.enqueue SendUpdateReminders.new }


#, :at => '08:00'
