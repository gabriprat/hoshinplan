class HoboMigration15 < ActiveRecord::Migration
  def self.up
    add_column :indicators, :last_value, :decimal
  end

  def self.down
    remove_column :indicators, :last_value
  end
end
