class HoboMigration4 < ActiveRecord::Migration
  def self.up
    change_column :tasks, :status, :string, :default => :active, :limit => 255, :null => false
  end

  def self.down
    change_column :tasks, :status, :string
  end
end
