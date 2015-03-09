class OpenidToAuth < ActiveRecord::Migration
  def self.up
    add_column :auth_providers, :type, :string
    add_column :auth_providers, :openid_url, :string

    change_column :users, :preferred_view, :string, :limit => 255, :default => :expanded

    add_index :auth_providers, [:type]
  end

  def self.down
    remove_column :auth_providers, :type
    remove_column :auth_providers, :openid_url

    change_column :users, :preferred_view, :string, default: "expanded"

    remove_index :auth_providers, :name => :index_auth_providers_on_type rescue ActiveRecord::StatementInvalid
  end
end
