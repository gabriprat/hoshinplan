
module Resque
  class TaggedVeryVerboseFormatter 
    include ActiveSupport::TaggedLogging::Formatter
    def call(serverity, datetime, progname, msg)
      time = Time.now.strftime('%H:%M:%S %Y-%m-%d')
      "** [#{time}] #$$: #{msg}\n"
    end
    def current_tags
      super
    end
  end
end