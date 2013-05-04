class HoboMigration3 < ActiveRecord::Migration
  def self.up
    remove_column :areas, :position
  end

  def self.down
    add_column :areas, :position, :integer
  end
end
