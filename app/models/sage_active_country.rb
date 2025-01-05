class SageActiveCountry < ActiveRecord::Base
  hobo_model

  fields do
    name :string, :required
    iso_code_alpha2 :string, :required, :index => true, :unique => true
    iso_code_alpha3 :string, :required, :unique
    iso_number :string, :required, :unique
    legislation_country_code :string
    vies_code :string, :unique
    creationDate :datetime, :required
    modificationDate :datetime, :required
  end

  attr_accessible :id, :name, :iso_code_alpha2, :iso_code_alpha3, :iso_number, :legislation_country_code, :vies_code, :creationDate, :modificationDate
end 