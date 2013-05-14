class HoboMigration18 < ActiveRecord::Migration
  def self.up
    change_column :indicators, :higher, :boolean, :default => true
  end

  def self.down
    change_column :indicators, :higher, :boolean
  end
end
