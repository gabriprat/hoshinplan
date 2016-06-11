class SamlProvider < AuthProvider

  include REXML
  fields do
    issuer      :string
    sso_url     :string
    cert        :text
    fingerprint :string
    id_format   :string
  end
  attr_accessible :issuer, :sso_url, :cert, :fingerprint, :id_format, :metadata_xml
  attr_accessor :metadata_xml, type: :string
  

  def issuer=(val)
    super(val) unless val.blank?
  end
  def sso_url=(val)
    super(val) unless val.blank?
  end
  def cert=(val)
    super(val) unless val.blank?
  end
  def fingerprint=(val)
    super(val) unless val.blank?
  end
  def id_format=(val)
    super(val) unless val.blank?
  end
    
    
  def metadata_xml=(metadata_xml)
    parser = IdpMetadataParser.new
    res = parser.parse(metadata_xml)
    self.issuer ||= res.issuer
    self.sso_url ||= res.idp_sso_target_url
    self.cert ||= res.idp_cert
    self.fingerprint ||= res.idp_cert_fingerprint
    self.id_format ||= 'urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress'
  end
  
  def metadata_xml
  end

end


require "base64"
require "zlib"
require "cgi"
require "rexml/document"
require "rexml/xpath"
include REXML

    class IdpMetadataParser
      METADATA = "urn:oasis:names:tc:SAML:2.0:metadata"
      DSIG     = "http://www.w3.org/2000/09/xmldsig#"
      attr_reader :document
      def parse_remote(url, validate_cert = true)
        idp_metadata = get_idp_metadata(url, validate_cert)
        parse(idp_metadata)
      end
      def parse(idp_metadata)
        @document = REXML::Document.new(idp_metadata)
        OneLogin::RubySaml::Settings.new.tap do |settings|
          settings.idp_sso_target_url = single_signon_service_url
          settings.idp_slo_target_url = single_logout_service_url
          settings.idp_cert_fingerprint = fingerprint
          settings.issuer = issuer
          settings.idp_cert = OpenSSL::X509::Certificate.new(certificate).to_pem
        end
      end
      
      private
      # Retrieve the remote IdP metadata from the URL or a cached copy
      # # returns a REXML document of the metadata
      def get_idp_metadata(url, validate_cert)
        uri = URI.parse(url)
        if uri.scheme == "http"
          response = Net::HTTP.get_response(uri)
          meta_text = response.body
        elsif uri.scheme == "https"
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          # Most IdPs will probably use self signed certs
          if validate_cert
            http.verify_mode = OpenSSL::SSL::VERIFY_PEER
          else
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          end
          get = Net::HTTP::Get.new(uri.request_uri)
          response = http.request(get)
          meta_text = response.body
        end
        meta_text
      end
      def issuer
        node = REXML::XPath.first(document, "/md:EntityDescriptor/@entityID", {"md" => METADATA})
        node.value if node
      end
      def single_signon_service_url
        node = REXML::XPath.first(document, "/md:EntityDescriptor/md:IDPSSODescriptor/md:SingleSignOnService/@Location", { "md" => METADATA })
        node.value if node
      end
      def single_logout_service_url
        node = REXML::XPath.first(document, "/md:EntityDescriptor/md:IDPSSODescriptor/md:SingleLogoutService/@Location", { "md" => METADATA })
        node.value if node
      end
      def certificate
        @certificate ||= begin
          node = REXML::XPath.first(document, "/md:EntityDescriptor/md:IDPSSODescriptor/md:KeyDescriptor[@use='signing']/ds:KeyInfo/ds:X509Data/ds:X509Certificate", { "md" => METADATA, "ds" => DSIG })
          Base64.decode64(node.text) if node
        end
      end
      def fingerprint
        @fingerprint ||= begin
          if certificate
            cert = OpenSSL::X509::Certificate.new(certificate)
            Digest::SHA1.hexdigest(cert.to_der).upcase.scan(/../).join(":")
          end
        end
      end
    end
