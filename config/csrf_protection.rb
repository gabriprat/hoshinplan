class CsrfProtection < ActionController::Base
  def incoming(message, request, callback)
    message_token = message['ext'] && message['ext'].delete('csrfToken')

    begin
      unless !request || valid_authenticity_token?(request.session, message_token)
        message['error'] = '401::Access denied'
      end
    rescue Exception
      message['error'] = '401::Access denied'
    end

    callback.call(message)
  end
end