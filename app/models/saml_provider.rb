class SamlProvider < AuthProvider

  fields do
    issuer      :string
    sso_url     :string
    cert        :text
    fingerprint :string
    id_format   :string
  end
  attr_accessible :issuer, :sso_url, :cert, :fingerprint, :id_format

end