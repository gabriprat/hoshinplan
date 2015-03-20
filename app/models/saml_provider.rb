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
    parser = OneLogin::RubySaml::IdpMetadataParser.new
    res = parser.parse(metadata_xml)
    cert =  XPath.first(parser.document, "//ds:X509Certificate").text
    self.issuer ||= parser.document.root.attribute('entityID').value
    self.sso_url ||= res.idp_sso_target_url
    self.cert ||= "-----BEGIN CERTIFICATE----- \n" + cert + "\n-----END CERTIFICATE-----"
    self.fingerprint ||= res.idp_cert_fingerprint
    self.id_format ||= 'urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress'
  end
  
  def metadata_xml
  end

end