class HoboMigration12 < ActiveRecord::Migration
  def self.up
    change_column :users, :state, :string, :default => "active", :limit => 255

    add_column :tasks, :show_on_parent, :boolean
  end

  def self.down
    change_column :users, :state, :string, :default => "inactive"

    remove_column :tasks, :show_on_parent
  end
end
