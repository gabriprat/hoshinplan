Apipie.configure do |config|
  config.app_name                = "Hoshinplan"
  config.api_base_url            = ""
  config.doc_base_url            = "/apidocs"
  config.app_info                = ""
  # where is your API defined?
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/**/*.rb"
end
