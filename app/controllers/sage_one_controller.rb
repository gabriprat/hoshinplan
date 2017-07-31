class SageOneController < ApplicationController

  hobo_controller

  def auth
    redirect_to SageOne.config[:auth_endpoint] + "/central?response_type=code&client_id=#{SageOne.config[:client_id]}&redirect_uri=#{SageOne.config[:callback_url]}"
  end

  def callback
    if params[:code].present?
      SageOne.exchange_code_for_token(params[:code])
    end
    render text: 'OK!'
  end

  def sales_invoices
    render json: SageOne.sales_invoices(params[:page], params[:items_per_page])
  end

  def sales_invoice
    render json: SageOne.sales_invoice(params[:id])
  end

  def contacts
    render json: SageOne.contacts(params[:page], params[:items_per_page], params[:search], params[:email])
  end

  def contact
    render json: SageOne.contact(params[:id])
  end

  def create_contact
    render json: SageOne.create_contact
  end

  def create_invoices
    render json: SageOne.create_invoices
  end

  def send_invoice
    UserCompanyMailer.invoice(params[:id]).deliver_later
    render text: 'OK!'
  end

  def ledger_accounts
    render json: SageOne.ledger_accounts(params[:page], params[:items_per_page])
  end

  def tax_rates
    render json: SageOne.tax_rates(params[:page], params[:items_per_page])
  end

  def renew_token
    render json: SageOne.renew_token!
  end
end
