class HoboMigration3 < ActiveRecord::Migration
  def self.up
    add_column :tasks, :status, :string

    remove_column :indicators, :old_values_count
  end

  def self.down
    remove_column :tasks, :status

    add_column :indicators, :old_values_count, :integer, :default => 0, :null => false
  end
end
