class HoboMigration1 < ActiveRecord::Migration
  def self.up
    remove_column :areas, :objectives_count
  end

  def self.down
    add_column :areas, :objectives_count, :integer, :default => 0, :null => false
  end
end
