require 'open-uri'
require 'net/https'

module Net
  class HTTP
    alias_method :original_use_ssl=, :use_ssl=

    def use_ssl=(flag)
      path = '/etc/pki/tls/certs/ca-bundle.trust.crt'
      self.ca_file = Rails.root.join(path).to_s if File.exist?(path)
      self.verify_mode = OpenSSL::SSL::VERIFY_PEER
      self.original_use_ssl = flag
    end
  end
end