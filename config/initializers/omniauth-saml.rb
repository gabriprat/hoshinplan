SamlProvider.all.each {|prov|
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :saml,
      :name => 'saml_' + prov.email_domain,
      :assertion_consumer_service_url     => 'http://' + Rails.application.routes.default_url_options[:host] + "/auth/saml_" + prov.email_domain + "/callback",
      :issuer                             => prov.issuer,
      :idp_sso_target_url                 => prov.sso_url,
      :idp_sso_target_url_runtime_params  => {:original_request_param => :mapped_idp_param},
      :idp_cert                           => prov.cert.to_s,
      :idp_cert_fingerprint               => prov.fingerprint,
      :idp_cert_fingerprint_validator     => lambda { |fingerprint| fingerprint },
      :name_identifier_format             => prov.id_format
  end
}

class SamlDynamicRouter
  def self.load
    Hoshinplan::Application.routes.draw do
      SamlProvider.all.each do |prov|
        Rails.logger.debug "Routing #{prov.email_domain}"
        get "/#{prov.email_domain}", :to => redirect('/auth/saml_' + prov.email_domain)
      end
    end
  end

  def self.reload
    Hoshinplan::Application.routes_reloader.reload!
  end
end