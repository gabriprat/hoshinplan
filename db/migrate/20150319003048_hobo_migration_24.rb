class HoboMigration24 < ActiveRecord::Migration
  def self.up
    change_column :users, :preferred_view, :string, :limit => 255, :default => :expanded

    add_index :tasks, [:hoshin_id, :status]
  end

  def self.down
    change_column :users, :preferred_view, :string, default: "expanded"

    remove_index :tasks, :name => :index_tasks_on_hoshin_id_and_status rescue ActiveRecord::StatementInvalid
  end
end
