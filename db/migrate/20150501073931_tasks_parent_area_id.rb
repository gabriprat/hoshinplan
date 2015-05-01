class TasksParentAreaId < ActiveRecord::Migration
  def self.up
    change_column :users, :preferred_view, :string, :limit => 255, :default => :compact

    add_column :tasks, :parent_area_id, :integer

    add_index :tasks, [:parent_area_id]
  end

  def self.down
    change_column :users, :preferred_view, :string, default: "compact"

    remove_column :tasks, :parent_area_id

    remove_index :tasks, :name => :index_tasks_on_parent_area_id rescue ActiveRecord::StatementInvalid
  end
end
