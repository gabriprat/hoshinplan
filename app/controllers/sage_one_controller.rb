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

end
