class HoboMigration16 < ActiveRecord::Migration
  def self.up
    change_column :indicators, :min_value, :decimal, :default => 0.0
    change_column :indicators, :max_value, :decimal, :default => 100.0
    change_column :indicators, :goal, :decimal, :default => 100.0
  end

  def self.down
    change_column :indicators, :min_value, :decimal
    change_column :indicators, :max_value, :decimal
    change_column :indicators, :goal, :decimal
  end
end
