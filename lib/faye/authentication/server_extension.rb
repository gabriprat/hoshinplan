require 'faye'

module Faye
  module Authentication
    class ServerExtensionWithCreator
      include Faye::Logging

      def initialize(secret, options = {})
        @options = options
        @secret = secret.to_s
      end

      def incoming(message, callback)
        if Faye::Authentication.authentication_required?(message, @options)
          begin
            creator_id = nil
            if message.key('data')
              creator_id = message['data'].key?('creatorId') ? message['data']['creatorId'] : nil
              creator_id = nil if creator_id == 'dont_validate'
            else
              creator_id = 'dont_validate'
            end
            Faye::Authentication.validate(message['signature'],
                                          message['subscription'] || message['channel'],
                                          message['clientId'],
                                          creator_id,
                                          @secret)
          rescue AuthError => exception
            message['error'] = case exception
                                 when ExpiredError then 'Expired signature'
                                 when PayloadError then 'Required argument not signed'
                                 else 'Invalid signature'
                               end
          end
        end
        callback.call(message)
      end
    end
  end
end