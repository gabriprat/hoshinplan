class OpenidProviders < ActiveRecord::Migration
  def self.up
    create_table :openid_providers do |t|
      t.string   :domain
      t.string   :url
      t.datetime :created_at
      t.datetime :updated_at
    end
  end

  def self.down
    drop_table :openid_providers
  end
end
