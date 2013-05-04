class HoboMigration6 < ActiveRecord::Migration
  def self.up
    add_column :tasks, :area_id, :integer

    add_column :indicators, :area_id, :integer

    add_index :tasks, [:area_id]

    add_index :indicators, [:area_id]
  end

  def self.down
    remove_column :tasks, :area_id

    remove_column :indicators, :area_id

    remove_index :tasks, :name => :index_tasks_on_area_id rescue ActiveRecord::StatementInvalid

    remove_index :indicators, :name => :index_indicators_on_area_id rescue ActiveRecord::StatementInvalid
  end
end
