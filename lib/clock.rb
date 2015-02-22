require File.expand_path('../../config/boot',        __FILE__)
require File.expand_path('../../config/environment', __FILE__)
Dir['../../config/jobs/*.rb'].each {|file| require File.expand_path(file)}
include Clockwork

every(1.minute, 'update_indicators') { Delayed::Job.enqueue Jobs::UpdateIndicators.new }


#, :at => '08:00'
