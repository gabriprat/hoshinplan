module Resque
  module Failure
    class Newrelic < Base
      def save
      	worker.log exception.backtrace.join("\n")
      	Nr.track_exception(exception, nil)
      end
    end
  end
end