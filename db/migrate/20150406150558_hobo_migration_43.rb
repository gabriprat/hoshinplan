class HoboMigration43 < ActiveRecord::Migration
  def self.up
    change_column :users, :preferred_view, :string, :limit => 255, :default => :expanded

    remove_column :payments, :raw_post
  end

  def self.down
    change_column :users, :preferred_view, :string, default: "expanded"

    add_column :payments, :raw_post, :text
  end
end
