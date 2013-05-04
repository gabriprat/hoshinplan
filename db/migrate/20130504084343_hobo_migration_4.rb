class HoboMigration4 < ActiveRecord::Migration
  def self.up
    add_column :areas, :position, :integer
  end

  def self.down
    remove_column :areas, :position
  end
end
