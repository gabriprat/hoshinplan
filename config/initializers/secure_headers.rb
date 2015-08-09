::SecureHeaders::Configuration.configure do |config|
  config.hsts = false
  config.x_frame_options = 'DENY'
  config.x_content_type_options = "nosniff"
  config.x_xss_protection = {:value => 1, :mode => 'block'}
  config.x_download_options = 'noopen'
  config.x_permitted_cross_domain_policies = 'none'
  config.csp = {
    :default_src => "self static.hoshinplan.com",
    :enforce => false,
    :font_src => 'self fonts.gstatic.com static.hoshinplan.com',
    :frame_src => "self https:",
    :style_src => "self 'unsafe-inline' fonts.googleapis.com static.hoshinplan.com",
    :script_src => "self nonce 'unsafe-eval' static.hoshinplan.com app.box.com cdn.userreport.com settingsbucket.s3.amazonaws.com www.google-analytics.com ajax.cloudflare.com",
    :img_src => "self static.hoshinplan.com shield.sitelock.com cdn.mxpnl.com",
    :report_uri => '/uri-directive'
  }
  config.hpkp = false
end