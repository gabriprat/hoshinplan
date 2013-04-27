class HoboMigration2 < ActiveRecord::Migration
  def self.up
    add_column :indicators, :next_update, :date
    add_column :indicators, :goal, :decimal
    add_column :indicators, :max_value, :decimal
    add_column :indicators, :old_values_count, :integer, :default => 0, :null => false
    add_column :indicators, :created_at, :datetime
    add_column :indicators, :updated_at, :datetime
  end

  def self.down
    remove_column :indicators, :next_update
    remove_column :indicators, :goal
    remove_column :indicators, :max_value
    remove_column :indicators, :old_values_count
    remove_column :indicators, :created_at
    remove_column :indicators, :updated_at
  end
end
