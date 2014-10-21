Hoshinplan::Application.configure do
  
  config.log_level = :debug
  
  # Hobo: tell ActiveReload about dryml
  config.watchable_dirs[File.join(config.root, 'app/views')] = ['dryml']
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false
  
  config.eager_load = false
  
  #config.hobo.show_translation_keys = true 

  Rails.application.routes.default_url_options[:host] = 'es.hoshinplandev.com:5000'
  

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true 
  config.action_controller.perform_caching = false
  config.cache_store = :dalli_store
  
  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = true
config.action_mailer.delivery_method = :sendmail
# Defaults to:
# config.action_mailer.sendmail_settings = {
#   :location => '/usr/sbin/sendmail',
#   :arguments => '-i -t'
# }
config.action_mailer.raise_delivery_errors = true
config.action_mailer.asset_host = 'http://localhost:5000'
config.action_mailer.default_url_options = { host: 'localhost:5000', only_path: false }



  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Expands the lines which load the assets
  config.assets.debug = true
  config.paperclip_defaults = {
    :storage => :s3,
    :s3_credentials => {
      :bucket => ENV['S3_BUCKET_NAME'],
      :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
      :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
    }
  }
  
  config.session_store :cookie_store, :key => '_hoshinplan_session', :domain => :all
end
