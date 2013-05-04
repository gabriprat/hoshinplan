class HoboMigration8 < ActiveRecord::Migration
  def self.up
    add_column :indicators, :position, :integer
  end

  def self.down
    remove_column :indicators, :position
  end
end
