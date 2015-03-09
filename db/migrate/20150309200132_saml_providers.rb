class SamlProviders < ActiveRecord::Migration
  def self.up
    add_column :auth_providers, :issuer, :string
    add_column :auth_providers, :sso_url, :string
    add_column :auth_providers, :cert, :string
    add_column :auth_providers, :fingerprint, :string
    add_column :auth_providers, :id_format, :string
    change_column :auth_providers, :email_domain, :string, :limit => 255, :null => false

    change_column :users, :preferred_view, :string, :limit => 255, :default => :expanded

    add_index :auth_providers, [:email_domain], :unique => true
  end

  def self.down
    remove_column :auth_providers, :issuer
    remove_column :auth_providers, :sso_url
    remove_column :auth_providers, :cert
    remove_column :auth_providers, :fingerprint
    remove_column :auth_providers, :id_format
    change_column :auth_providers, :email_domain, :string

    change_column :users, :preferred_view, :string, default: "expanded"

    remove_index :auth_providers, :name => :index_auth_providers_on_email_domain rescue ActiveRecord::StatementInvalid
  end
end
