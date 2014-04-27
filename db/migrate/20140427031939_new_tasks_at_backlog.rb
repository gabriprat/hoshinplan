class NewTasksAtBacklog < ActiveRecord::Migration
  def self.up
    change_column :tasks, :status, :string, :limit => 255, :default => "backlog"
  end

  def self.down
    change_column :tasks, :status, :string, :default => "active"
  end
end
