Hoshinplan::Application.configure do
  
  config.log_level = :debug
  
  # Hobo: tell ActiveReload about dryml
  config.watchable_dirs[File.join(config.root, 'app/views')] = ['dryml']
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false
  
  config.eager_load = true
  
  #config.hobo.show_translation_keys = true 

  Rails.application.routes.default_url_options[:host] = 'www.hoshinplandev.com:5000'
  

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true 
  config.action_controller.perform_caching = false
  config.cache_store = :redis_store, { :expires_in => 8.day }
  
config.action_mailer.delivery_method = :smtp
# Send mails through mailcatcher gem. Start smtpserver by typing:
# $ mailcatcher
# View mails at http://127.0.0.1:1080
config.action_mailer.smtp_settings = { address: 'localhost',
                                         port: 1025 }
# Defaults to:
# config.action_mailer.sendmail_settings = {
#   :location => '/usr/sbin/sendmail',
#   :arguments => '-i -t'
# }
config.action_mailer.raise_delivery_errors = true
config.action_mailer.perform_deliveries = true
config.action_mailer.asset_host = 'http://www.hoshinplandev.com:5000'
config.action_mailer.default_url_options = { host: 'www.hoshinplandev.com:5000', only_path: false }

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Expands the lines which load the assets
  config.assets.debug = false
  config.assets.digest = false
  config.paperclip_defaults = {
      :url => "/system/:rails_env/:class/:attachment/:id_partition/:style/:filename",
      :path => ":rails_root/public:url"
    #:storage => :s3,
    #:s3_host_name => 's3-eu-west-1.amazonaws.com',
    #:s3_region => 'eu-west-1',
    #:path => '/:class/:attachment/:id_partition/:style/:filename',
    #:url => ':s3_domain_url',
    #:s3_credentials => {
    #  :bucket => ENV['S3_BUCKET_NAME'],
    #  :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
    #  :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
    #}
  }
  
  config.session_store :cookie_store, :key => '_hoshinplan_session', :domain => :all
  
  
    config.after_initialize do
      Rails.application.routes.default_url_options[:host] = 'www.hoshinplandev.com:5000'
    end
    
end
