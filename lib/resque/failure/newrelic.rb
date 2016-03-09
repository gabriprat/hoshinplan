module Resque
  module Failure
    class Newrelic < Base
      def save
        message = "Error in job execution: "
        message += exception.message if exception.message.present?
        worker.log exception.message
      	worker.log exception.backtrace.join("\n") if exception.backtrace.present?
      	Nr.track_exception(exception, nil)
      end
    end
  end
end