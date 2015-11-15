Hoshinplan::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  config.eager_load = true

  Rails.application.routes.default_url_options[:host] = 'www.hoshinplan.com'

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {
            :address        => 'smtp.sendgrid.net',
            :port           => '587',
            :authentication => :plain,
            :user_name      => ENV['SENDGRID_USERNAME'],
            :password       => ENV['SENDGRID_PASSWORD'],
            :domain         => 'hoshinplan.com',
            :enable_starttls_auto => true
    }
  config.action_mailer.asset_host = 'http://static.hoshinplan.com'
  config.action_mailer.default_url_options = { host: 'www.hoshinplan.com', only_path: false }
  

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_files = true
  config.static_cache_control = "max-age=315576000, public" #10 years

  # Compress JavaScripts and CSS
  config.assets.css_compressor = :sass
  config.assets.js_compressor = :uglify

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to nil and saved in location specified by config.assets.prefix
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = !Rails.configuration.ssl_disable
  config.ssl_options = { exclude: proc { |env| env['PATH_INFO'].start_with?('/health_check') } }

  # See everything in the log (default is :info)
  config.log_level = ENV['LOG_LEVEL'].blank? ? :info : ENV['LOG_LEVEL']

  # Prepend all log lines with the following tags
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production
  #config.cache_store = :dalli_store, nil, { :expires_in => 8.day, :compress => true }
  config.cache_store = :redis_store, { :expires_in => 8.day }
  #config.cache_store = :redis_store, 'redis://rediscloud:E2rOg7rZl9fIpgtp@pub-redis-18280.eu-west-1-1.2.ec2.garantiadata.com:18280', { :expires_in => 5.days }
  #config.hobo.stable_cache_store = :redis_store, 'redis://rediscloud:E2rOg7rZl9fIpgtp@pub-redis-18280.eu-west-1-1.2.ec2.garantiadata.com:18280'

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  config.action_controller.asset_host = 'static.hoshinplan.com'

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w( search.js )

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  #config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale between a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  config.paperclip_defaults = {
    :storage => :s3,
    :s3_protocol => :https,
    :s3_host_name => 's3-eu-west-1.amazonaws.com',
    :path => '/:class/:attachment/:id_partition/:style/:filename',
    :url => ':s3_domain_url',
    :s3_credentials => {
      :bucket => ENV['S3_BUCKET_NAME'],
      :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
      :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
    }
  }
  
  config.session_store ActionDispatch::Session::CacheStore, :expire_after => 15.days, :domain => :all
end


