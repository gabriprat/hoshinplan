class HoboMigration36 < ActiveRecord::Migration
  def self.up
    add_column :users, :payments_count, :integer, :default => 0, :null => false
    change_column :users, :preferred_view, :string, :limit => 255, :default => :expanded
  end

  def self.down
    remove_column :users, :payments_count
    change_column :users, :preferred_view, :string, default: "expanded"
  end
end
