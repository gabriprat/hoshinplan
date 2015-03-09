class OpenidProvider < AuthProvider

  fields do
    openid_url    :string
  end
  attr_accessible :openid_url
  
end
