class HierarchyCorrect < ActiveRecord::Migration
  def self.up
    add_column :objectives, :indicators_count, :integer, :default => 0, :null => false
    add_column :objectives, :tasks_count, :integer, :default => 0, :null => false

    rename_column :tasks, :area_id, :objective_id

    remove_column :areas, :indicators_count
    remove_column :areas, :tasks_count

    rename_column :indicators, :area_id, :objective_id

    remove_index :tasks, :name => :index_tasks_on_area_id rescue ActiveRecord::StatementInvalid
    add_index :tasks, [:objective_id]

    remove_index :indicators, :name => :index_indicators_on_area_id rescue ActiveRecord::StatementInvalid
    add_index :indicators, [:objective_id]
  end

  def self.down
    remove_column :objectives, :indicators_count
    remove_column :objectives, :tasks_count

    rename_column :tasks, :objective_id, :area_id

    add_column :areas, :indicators_count, :integer, :default => 0, :null => false
    add_column :areas, :tasks_count, :integer, :default => 0, :null => false

    rename_column :indicators, :objective_id, :area_id

    remove_index :tasks, :name => :index_tasks_on_objective_id rescue ActiveRecord::StatementInvalid
    add_index :tasks, [:area_id]

    remove_index :indicators, :name => :index_indicators_on_objective_id rescue ActiveRecord::StatementInvalid
    add_index :indicators, [:area_id]
  end
end
