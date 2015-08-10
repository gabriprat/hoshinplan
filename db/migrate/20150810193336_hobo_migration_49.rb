class HoboMigration49 < ActiveRecord::Migration
  def self.up
    change_column :users, :preferred_view, :string, :limit => 255, :default => :expanded

    change_column :tasks, :feeling, :string, :limit => 255, :null => false, :default => :smile
    change_column :tasks, :confidence, :float
    change_column :tasks, :impact, :float
    change_column :tasks, :effort, :float
  end

  def self.down
    change_column :users, :preferred_view, :string, default: "expanded"

    change_column :tasks, :feeling, :string, default: "smile",   null: false
    change_column :tasks, :confidence, :decimal
    change_column :tasks, :impact, :decimal
    change_column :tasks, :effort, :decimal
  end
end
