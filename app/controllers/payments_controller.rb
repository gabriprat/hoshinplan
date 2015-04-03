class PaymentsController < ApplicationController

  hobo_model_controller

  protect_from_forgery :except => [:paypal_ipn] #Otherwise the request from PayPal wouldn't make it to the controller
      
  
  def paypal_ipn
    if Payment.where(txn_id: params[:txn_id]).exists?
      fail "Transaction already processed #{params[:txn_id]}"
    end
    rp = request.raw_post
    response = validate_IPN_notification(rp)
    case response
    when "VERIFIED"
      if params[:payment_status] != "Completed"
        fail "payment_status not Completed: #{params[:payment_status]}."
      end
      if params[:receiver_email] != ENV['PAYPAL_RECEIVER_EMAIL']
        fail "receiver_email not #{ENV['PAYPAL_RECEIVER_EMAIL']}: #{params[:receiver_email]}."
      end
      # check that paymentAmount/paymentCurrency are correct
      # process payment
    when "INVALID"
      # log for investigation
    else
      # error
    end
    payment = Payment.user_new(current_user)
    payment.user = current_user
    payment.txn_id = params[:txn_id]
    payment.raw_post = rp
    self.this = payment
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
  
  def pricing
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
