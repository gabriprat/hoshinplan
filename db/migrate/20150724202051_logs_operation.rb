class LogsOperation < ActiveRecord::Migration
  def self.up
    change_column :users, :preferred_view, :string, :limit => 255, :default => :expanded

    change_column :tasks, :feeling, :string, :limit => 255, :null => false, :default => :smile

    add_column :logs, :operation, :string, :null => false
  end

  def self.down
    change_column :users, :preferred_view, :string, default: "expanded"

    change_column :tasks, :feeling, :string, default: "smile",   null: false

    remove_column :logs, :operation
  end
end
