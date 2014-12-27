class HoboMigration23 < ActiveRecord::Migration
  def self.up
    change_column :users, :preferred_view, :string, :limit => 255, :default => :expanded

    change_column :tasks, :objective_id, :integer, :null => false
  end

  def self.down
    change_column :users, :preferred_view, :string, default: "expanded"

    change_column :tasks, :objective_id, :integer
  end
end
