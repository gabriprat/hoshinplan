class Tasks < ActiveRecord::Migration
  def self.up
    add_column :tasks, :type, :string

    add_index :tasks, [:type]
  end

  def self.down
    remove_column :tasks, :type

    remove_index :tasks, :name => :index_tasks_on_type rescue ActiveRecord::StatementInvalid
  end
end
