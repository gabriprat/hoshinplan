class PaymentsController < ApplicationController

  hobo_model_controller

  auto_actions :new
  
  protect_from_forgery :except => [:paypal_ipn] #Otherwise the request from PayPal wouldn't make it to the controller
        
  def paypal_ipn
    if params[:txn_type] != "subscr_payment"
      render :nothing => true
      return
    end
    payment = Payment.where(txn_id: params[:txn_id]).first
    if payment
      fail "Transaction already processed #{params[:txn_id]}" unless Rails.env.development?
      Payment.delete(payment.id) if Rails.env.development?
    end
    rp = request.raw_post
    payment = Payment.new
    payment = Payment.new
    payment.user = User.unscoped.find(params[:custom]) if params[:custom]
    payment.txn_id = params[:txn_id]
    payment.raw_post = rp
    payment.sandbox = params[:test_ipn]=='1'
    response = "VERIFIED" if  Rails.env.development?
    response ||= validate_IPN_notification(rp, test=payment.sandbox) 
    case response
    when "VERIFIED"
      payment.status = "VERIFIED"
      if params[:payment_status] != "Completed"
        fail "payment_status not Completed: #{params[:payment_status]}."
      end
      if params[:receiver_email] != ENV['PAYPAL_RECEIVER_EMAIL'] && params[:receiver_email] != "jo-facilitator@gabriel.prat.name"
        fail "receiver_email not #{ENV['PAYPAL_RECEIVER_EMAIL']}: #{params[:receiver_email]}."
      end
      # check that paymentAmount/paymentCurrency are correct
      
      if params[:mc_currency] != "USD"
        fail "mc_currency not USD: #{params[:mc_currency]}."
      end      
      case params[:mc_gross].to_f
      when 20
        payment.product = "STARTUP"
      when 150
        payment.product = "ENTERPRISE"
      else
        fail "mc_gross not 20 or 150: #{params[:mc_gross]}."
      end
      company = Company.unscoped.find(params[:custom])
      company.plan = payment.product
      company.save!
      log_event("Paypal payment", {objid: payment.id, product: payment.product})
    when "INVALID"
      payment.status = "INVALID"
      track_exception "Status INVALID: " + rp.to_s 
    else
      payment.status = "Unexpected response: #{response}"
      fail "Unexpected status #{response}: " + rp.to_s  #Fail so Paypal retries
    end
    # process payment
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
  
  def create
    fail "Missing company" if params[:company].blank?
    sandbox = Rails.env.development? || ENV['PAYPAL_SANDBOX'] == "1"
    product = params[:product]
    @host = sandbox ? 'www.sandbox.paypal.com' : 'www.paypal.com'
    button = PaypalButton.where(product: product).first
    @id = sandbox ? button.id_paypal_sandbox : button.id_paypal
    @company_id = params[:company]
    company = Company.find(params[:company])
    company.plan = "PENDING"
    company.save!
    log_event("Paypal redirection", {product: product})
  end

  protected 
  def validate_IPN_notification(raw, test=false)
    if (test)
      uri = URI.parse('https://sandbox.paypal.com/cgi-bin/webscr?cmd=_notify-validate')
    else
      uri = URI.parse('https://www.paypal.com/cgi-bin/webscr?cmd=_notify-validate')
    end
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
