require File.expand_path('../../config/boot',        __FILE__)
require File.expand_path('../../config/environment', __FILE__)
require File.expand_path('../../config/jobs/remainders', __FILE__)
include Clockwork

#every(1.day, 'remainders') { Delayed::Job.enqueue SendUpdateReminders.new }


#, :at => '08:00'
