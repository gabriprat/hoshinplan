class HoboMigration19 < ActiveRecord::Migration
  def self.up
    add_column :openid_providers, :email_domain, :string
    remove_column :openid_providers, :domain
  end

  def self.down
    remove_column :openid_providers, :email_domain
    add_column :openid_providers, :domain, :string
  end
end
