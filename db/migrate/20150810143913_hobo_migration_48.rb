class HoboMigration48 < ActiveRecord::Migration
  def self.up
    change_column :users, :preferred_view, :string, :limit => 255, :default => :expanded

    rename_column :tasks, :uncertainty, :confidence
    change_column :tasks, :feeling, :string, :limit => 255, :null => false, :default => :smile
  end

  def self.down
    change_column :users, :preferred_view, :string, default: "expanded"

    rename_column :tasks, :confidence, :uncertainty
    change_column :tasks, :feeling, :string, default: "smile",   null: false
  end
end
