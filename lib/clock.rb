require File.expand_path('../../config/boot',        __FILE__)
require File.expand_path('../../config/environment', __FILE__)

require File.expand_path('../../config/jobs/base_job.rb',        __FILE__)
Dir['config/jobs/*.rb'].each {|file| require File.expand_path('../../' + file, __FILE__)}
require 'clockwork'
require 'clockwork/database_events'

module Clockwork
  # required to enable database syncing support
  Clockwork.manager = DatabaseEvents::Manager.new
  sync_database_events model: ClockworkEvent, every: 1.minute do |event|
    Resque.enqueue event.jobClass
  end
end
