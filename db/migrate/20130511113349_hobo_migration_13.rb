class HoboMigration13 < ActiveRecord::Migration
  def self.up
    add_column :indicators, :last_update, :date
    add_column :indicators, :min_value, :decimal
  end

  def self.down
    remove_column :indicators, :last_update
    remove_column :indicators, :min_value
  end
end
