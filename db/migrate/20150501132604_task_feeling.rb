class TaskFeeling < ActiveRecord::Migration
  def self.up
    change_column :users, :preferred_view, :string, :limit => 255, :default => :compact

    add_column :tasks, :feeling, :string, :default => :smile, :null => false
  end

  def self.down
    change_column :users, :preferred_view, :string, default: "compact"

    remove_column :tasks, :feeling
  end
end
