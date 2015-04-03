class PaymentsController < ApplicationController

  hobo_model_controller

  protect_from_forgery :except => [:paypal_ipn] #Otherwise the request from PayPal wouldn't make it to the controller
      
  
  def paypal_ipn
    rp = request.raw_post
    response = validate_IPN_notification(rp)
    case response
    when "VERIFIED"
      # check that paymentStatus=Completed
      # check that txnId has not been previously processed
      # check that receiverEmail is your Primary PayPal email
      # check that paymentAmount/paymentCurrency are correct
      # process payment
    when "INVALID"
      # log for investigation
    else
      # error
    end
    self.this = Payment.user_new(current_user)
    self.this.user = current_user
    self.this.raw_post = rp
    hobo_create {
      render :nothing => true
    }
  end
  
  def test_paypal_ipn
  end
  
  def cancel
  end
  
  def correct
  end

  protected 
  def validate_IPN_notification(raw)
    uri = URI.parse('https://www.paypal.com/cgi-bin/webscr?cmd=_notify-validate')
    http = Net::HTTP.new(uri.host, uri.port)
    http.open_timeout = 60
    http.read_timeout = 60
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    http.use_ssl = true
    response = http.post(uri.request_uri, raw,
                         'Content-Length' => "#{raw.size}",
                         'User-Agent' => "My custom user agent"
                       ).body
  end
end
