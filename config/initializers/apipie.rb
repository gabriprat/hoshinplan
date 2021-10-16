Apipie.configure do |config|
  config.app_name                = "Hoshinplan"
  config.api_base_url            = ""
  config.doc_base_url            = "/apidocs"
  config.app_info                = ""
  config.translate               = false
  config.default_locale          = 'en'
  config.copyright               = "&copy; " + Date.today.year.to_s + " Hoshinplan Strategy S.L."
  config.use_cache = Rails.env.production?
  # where is your API defined?
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/**/*.rb"
end
