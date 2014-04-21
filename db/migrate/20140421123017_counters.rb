class Counters < ActiveRecord::Migration
  def self.up
    add_column :areas, :objectives_count, :integer, :default => 0, :null => false
    add_column :areas, :kpis_count, :integer, :default => 0, :null => false
    add_column :areas, :tasks_count, :integer, :default => 0, :null => false

    add_column :hoshins, :goals_count, :integer, :default => 0, :null => false
    add_column :hoshins, :kpis_count, :integer, :default => 0, :null => false
    add_column :hoshins, :tasks_count, :integer, :default => 0, :null => false

    add_column :indicator_histories, :responsible_id, :integer

    add_column :indicators, :hoshin_id, :integer

    add_column :tasks, :hoshin_id, :integer

    add_index :indicator_histories, [:responsible_id]

    add_index :indicators, [:hoshin_id]

    add_index :tasks, [:hoshin_id]
  end

  def self.down
    remove_column :areas, :objectives_count
    remove_column :areas, :kpis_count
    remove_column :areas, :tasks_count

    remove_column :hoshins, :goals_count
    remove_column :hoshins, :kpis_count
    remove_column :hoshins, :tasks_count

    remove_column :indicator_histories, :responsible_id

    remove_column :indicators, :hoshin_id

    remove_column :tasks, :hoshin_id

    remove_index :indicator_histories, :name => :index_indicator_histories_on_responsible_id rescue ActiveRecord::StatementInvalid

    remove_index :indicators, :name => :index_indicators_on_hoshin_id rescue ActiveRecord::StatementInvalid

    remove_index :tasks, :name => :index_tasks_on_hoshin_id rescue ActiveRecord::StatementInvalid
  end
end
