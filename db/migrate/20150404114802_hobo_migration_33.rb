class HoboMigration33 < ActiveRecord::Migration
  def self.up
    change_column :users, :preferred_view, :string, :limit => 255, :default => :expanded

    add_column :companies, :plan, :string, :default => "basic"
  end

  def self.down
    change_column :users, :preferred_view, :string, default: "expanded"

    remove_column :companies, :plan
  end
end
