class HoboMigration7 < ActiveRecord::Migration
  def self.up
    add_column :objectives, :position, :integer
  end

  def self.down
    remove_column :objectives, :position
  end
end
