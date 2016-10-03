::SecureHeaders::Configuration.default do |config|
  config.hsts = "max-age=#{1.years.to_i}; includeSubDomains; preload"
  config.x_frame_options = "SAMEORIGIN"
  config.x_content_type_options = "nosniff"
  config.x_xss_protection = "1; mode=block"
  config.x_download_options = "noopen"
  config.x_permitted_cross_domain_policies = "none"
  config.csp = {
    :default_src => %w('self' d4i78hkg1rdv3.cloudfront.net static.hoshinplan.com *.userreport.com api.mixpanel.com),
    :report_only => false,
    :connect_src => %w('self' performance.typekit.net d4i78hkg1rdv3.cloudfront.net static.hoshinplan.com *.userreport.com api.mixpanel.com sqs.us-east-1.amazonaws.com),
    :font_src => %w('self' fonts.typekit.net fonts.gstatic.com d4i78hkg1rdv3.cloudfront.net static.hoshinplan.com staticdoc.hoshinplan.com data:),
    :frame_src => %w('self' checkout.stripe.com accounts.google.com docs.google.com *.userreport.com www.youtube.com www.googletagmanager.com),
    :style_src => %w('self' 'unsafe-inline' checkout.stripe.com use.typekit.net fonts.googleapis.com d4i78hkg1rdv3.cloudfront.net static.hoshinplan.com staticdoc.hoshinplan.com),
    :script_src => %w('self' 'unsafe-eval' 'unsafe-inline' www.googleadservices.com checkout.stripe.com use.typekit.net d4i78hkg1rdv3.cloudfront.net static.hoshinplan.com staticdoc.hoshinplan.com apis.google.com www.dropbox.com app.box.com *.userreport.com settingsbucket.s3.amazonaws.com www.google-analytics.com *.mxpnl.com www.googletagmanager.com),
    :img_src => %w('self' data: www.googleadservices.com googleads.g.doubleclick.net www.google.com www.google.es q.stripe.com p.typekit.net ping.typekit.net doc.hoshinplan.com d4i78hkg1rdv3.cloudfront.net static.hoshinplan.com staticdoc.hoshinplan.com hoshinplan.s3-eu-west-1.amazonaws.com shield.sitelock.com *.mxpnl.com stats.g.doubleclick.net www.google-analytics.com *.userreport.com sqs.us-east-1.amazonaws.com),
    :report_uri => %w(/uri_dir_reports)
  }
  config.hpkp = SecureHeaders::OPT_OUT
end