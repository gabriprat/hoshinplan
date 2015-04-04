class HoboMigration35 < ActiveRecord::Migration
  def self.up
    drop_table :openid_providers

    change_column :users, :preferred_view, :string, :limit => 255, :default => :expanded

    add_column :payments, :gross, :decimal, :precision => 8, :scale => 2
  end

  def self.down
    change_column :users, :preferred_view, :string, default: "expanded"

    remove_column :payments, :gross

    create_table "openid_providers", force: true do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "email_domain"
      t.string   "openid_url"
    end
  end
end
