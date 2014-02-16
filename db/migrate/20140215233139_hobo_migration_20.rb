class HoboMigration20 < ActiveRecord::Migration
  def self.up
    add_column :openid_providers, :openid_url, :string
    remove_column :openid_providers, :url
  end

  def self.down
    remove_column :openid_providers, :openid_url
    add_column :openid_providers, :url, :string
  end
end
