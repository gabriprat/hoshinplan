class TaskAttributes < ActiveRecord::Migration
  def self.up
    change_column :users, :preferred_view, :string, :limit => 255, :default => :expanded

    add_column :tasks, :uncertainty, :decimal
    add_column :tasks, :impact, :decimal
    add_column :tasks, :effort, :decimal
    change_column :tasks, :feeling, :string, :limit => 255, :null => false, :default => :smile
  end

  def self.down
    change_column :users, :preferred_view, :string, default: "expanded"

    remove_column :tasks, :uncertainty
    remove_column :tasks, :impact
    remove_column :tasks, :effort
    change_column :tasks, :feeling, :string, default: "smile",   null: false
  end
end
