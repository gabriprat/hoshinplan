class ClientApplication < ApplicationRecord
  require 'openssl'
  require 'base64'

  acts_as_paranoid

  hobo_model # Don't put anything above this

  fields do
    name :string, :required
    description :string
    key :string, :unique
    secret :string
    timestamps
    deleted_at    :datetime
  end
  index [:deleted_at]
  attr_accessible :name, :description
  attr_readonly :key, :secret
  
  belongs_to :user, :inverse_of => :client_applications

  before_create do |app|
    app.key = SecureRandom.hex
    app.secret = SecureRandom.hex
    app.user_id = acting_user.id
  end
  
  def self.current_app=(app)
    RequestStore.store[:client_app] = app
  end

  def self.current_app
    RequestStore.store[:client_app]
  end  
  
  def sign(data)
   Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest::Digest.new('sha256'), secret, data)).strip()
  end

  def sign_uri(uri)
    timestamp = Time.new.xmlschema
    data =  uri + "&timestamp=" + CGI::escape(timestamp.to_s)
    signature = self.sign(data)
    "#{data}&signature=#{signature}"
  end
  
  default_scope lambda { 
    where(:user_id =>  
        User.current_id ) }
  
  # --- Permissions --- #
  def create_permitted?
    true
  end

  def update_permitted?
    acting_user.administrator? || acting_user.respond_to?("id") && user_id == acting_user.id
  end

  def destroy_permitted?
    acting_user.administrator? || acting_user.respond_to?("id")  && user_id == acting_user.id
  end

  def view_permitted?(field)
    acting_user.administrator? || acting_user.respond_to?("id")  && user_id == acting_user.id
  end
 
end
