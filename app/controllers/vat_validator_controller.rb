
class VatValidatorController < ApplicationController

  hobo_controller

  def validate_vat
    value = params[:vat_number]
    country = params[:country]
    ret = validate_vat_number(country, value)
    render json: ret
  end

  def validate_vat_number(country, value)
    valid = false
    errors = []
    vat_number = Valvat.new(value)
    if Valvat::Utils::country_is_supported? country
      if !vat_number.valid?
        errors << t('errors.not_expected_format')
      else
        valid = country == 'ES' || vat_number.exist?
      end
    else
      #Consider valids all VAT numbers that we don't know how to validate
      valid = true
    end
    {valid: valid, errors: errors}
  end

end