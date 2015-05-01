class TaskParentObjectiveId < ActiveRecord::Migration
  def self.up
    change_column :users, :preferred_view, :string, :limit => 255, :default => :compact

    add_column :tasks, :parent_objective_id, :integer

    add_index :tasks, [:parent_objective_id]
  end

  def self.down
    change_column :users, :preferred_view, :string, default: "compact"

    remove_column :tasks, :parent_objective_id

    remove_index :tasks, :name => :index_tasks_on_parent_objective_id rescue ActiveRecord::StatementInvalid
  end
end
