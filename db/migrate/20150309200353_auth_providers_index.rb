class AuthProvidersIndex < ActiveRecord::Migration
  def self.up
    change_column :users, :preferred_view, :string, :limit => 255, :default => :expanded

    remove_index :auth_providers, :name => :index_auth_providers_on_email_domain rescue ActiveRecord::StatementInvalid
    add_index :auth_providers, [:email_domain, :type], :unique => true
  end

  def self.down
    change_column :users, :preferred_view, :string, default: "expanded"

    remove_index :auth_providers, :name => :index_auth_providers_on_email_domain_and_type rescue ActiveRecord::StatementInvalid
    add_index :auth_providers, [:email_domain], :unique => true
  end
end
