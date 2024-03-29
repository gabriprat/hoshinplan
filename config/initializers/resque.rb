require 'resque/failure/newrelic'
require 'resque/log_formatters/tagged_very_verbose_formatter'

Resque.logger = Logger.new(STDOUT)

Resque.before_first_fork = Proc.new { 
  Resque.logger.formatter = Resque::TaggedVeryVerboseFormatter.new
}

Resque.redis = $redis

#Resque.logger.formatter = Resque::VeryVerboseFormatter.new

Resque::Failure.backend = Resque::Failure::Newrelic
