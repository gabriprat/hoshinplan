::SecureHeaders::Configuration.default do |config|
  config.hsts = "max-age=#{1.years.to_i}; includeSubDomains; preload"
  config.x_frame_options = "SAMEORIGIN"
  config.x_content_type_options = "nosniff"
  config.x_xss_protection = "1; mode=block"
  config.x_download_options = "noopen"
  config.x_permitted_cross_domain_policies = "none"
  config.csp = {
    :default_src => %w('self' static.hoshinplan.com *.userreport.com api.mixpanel.com),
    :enforce => true,
    :connect_src => %w('self' static.hoshinplan.com *.userreport.com api.mixpanel.com sqs.us-east-1.amazonaws.com),
    :font_src => %w('self' fonts.gstatic.com static.hoshinplan.com staticdoc.hoshinplan.com data:),
    :frame_src => %w('self' accounts.google.com docs.google.com *.userreport.com www.youtube.com www.googletagmanager.com),
    :style_src => %w('self' 'unsafe-inline' fonts.googleapis.com static.hoshinplan.com staticdoc.hoshinplan.com),
    :script_src => %w('self' 'unsafe-eval' 'unsafe-inline' static.hoshinplan.com staticdoc.hoshinplan.com apis.google.com www.dropbox.com app.box.com *.userreport.com settingsbucket.s3.amazonaws.com www.google-analytics.com ajax.cloudflare.com cdn.mxpnl.com www.googletagmanager.com),
    :img_src => %w('self' doc.hoshinplan.com static.hoshinplan.com staticdoc.hoshinplan.com hoshinplan.s3-eu-west-1.amazonaws.com shield.sitelock.com cdn.mxpnl.com stats.g.doubleclick.net www.google-analytics.com *.userreport.com sqs.us-east-1.amazonaws.com sha1test.cloudflaressl.net sha2test.cloudflaressl.net),
    :report_uri => %w(/uri_dir_reports)
  }
  config.hpkp = false
end
