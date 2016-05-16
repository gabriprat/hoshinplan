class CountriesController < ApplicationController
  
  hobo_controller
    
  def complete_name
    render :json => ISO3166::Country.all.map { |c| 
      {
        id: c.alpha2, 
        name: c.translation(I18n.locale) || c.name, 
        taxes: (c.in_eu? ? c.vat_rates['standard'] : 0)
      }
    }
  end

end