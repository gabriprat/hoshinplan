class AuthProviders < ActiveRecord::Migration
  def self.up
    create_table :auth_providers do |t|
      t.string   :email_domain
      t.datetime :created_at
      t.datetime :updated_at
    end

    change_column :users, :preferred_view, :string, :limit => 255, :default => :expanded
  end

  def self.down
    change_column :users, :preferred_view, :string, default: "expanded"

    drop_table :auth_providers
  end
end
