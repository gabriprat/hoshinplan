class HoboMigration21 < ActiveRecord::Migration
  def self.up
    change_column :users, :preferred_view, :string, :limit => 255, :default => :expanded
  end

  def self.down
    change_column :users, :preferred_view, :string, default: "expanded"
  end
end
