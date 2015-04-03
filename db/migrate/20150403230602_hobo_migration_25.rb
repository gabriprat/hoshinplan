class HoboMigration25 < ActiveRecord::Migration
  def self.up
    change_column :users, :preferred_view, :string, :limit => 255, :default => :expanded

    add_column :payments, :raw_post, :text
  end

  def self.down
    change_column :users, :preferred_view, :string, default: "expanded"

    remove_column :payments, :raw_post
  end
end
