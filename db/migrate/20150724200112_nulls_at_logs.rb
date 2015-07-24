class NullsAtLogs < ActiveRecord::Migration
  def self.up
    change_column :users, :preferred_view, :string, :limit => 255, :default => :expanded

    change_column :tasks, :feeling, :string, :limit => 255, :null => false, :default => :smile

    change_column :logs, :hoshin_id, :integer, :null => true
    change_column :logs, :area_id, :integer, :null => true
    change_column :logs, :goal_id, :integer, :null => true
    change_column :logs, :objective_id, :integer, :null => true
    change_column :logs, :indicator_id, :integer, :null => true
    change_column :logs, :task_id, :integer, :null => true
  end

  def self.down
    change_column :users, :preferred_view, :string, default: "expanded"

    change_column :tasks, :feeling, :string, default: "smile",   null: false

    change_column :logs, :hoshin_id, :integer, null: false
    change_column :logs, :area_id, :integer, null: false
    change_column :logs, :goal_id, :integer, null: false
    change_column :logs, :objective_id, :integer, null: false
    change_column :logs, :indicator_id, :integer, null: false
    change_column :logs, :task_id, :integer, null: false
  end
end
