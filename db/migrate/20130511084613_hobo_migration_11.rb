class HoboMigration11 < ActiveRecord::Migration
  def self.up
    remove_column :hoshins, :ancestry
  end

  def self.down
    add_column :hoshins, :ancestry, :string
  end
end
