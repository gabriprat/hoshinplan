class Responsible < ActiveRecord::Migration
  def self.up
    add_column :objectives, :responsible_id, :integer
    remove_column :objectives, :responsible

    add_column :indicators, :responsible_id, :integer
    remove_column :indicators, :responsible

    add_column :tasks, :responsible_id, :integer
    remove_column :tasks, :responsible

    add_index :objectives, [:responsible_id]

    add_index :indicators, [:responsible_id]

    add_index :tasks, [:responsible_id]
  end

  def self.down
    remove_column :objectives, :responsible_id
    add_column :objectives, :responsible, :string

    remove_column :indicators, :responsible_id
    add_column :indicators, :responsible, :string

    remove_column :tasks, :responsible_id
    add_column :tasks, :responsible, :string

    remove_index :objectives, :name => :index_objectives_on_responsible_id rescue ActiveRecord::StatementInvalid

    remove_index :indicators, :name => :index_indicators_on_responsible_id rescue ActiveRecord::StatementInvalid

    remove_index :tasks, :name => :index_tasks_on_responsible_id rescue ActiveRecord::StatementInvalid
  end
end
