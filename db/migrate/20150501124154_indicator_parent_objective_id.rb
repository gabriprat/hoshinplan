class IndicatorParentObjectiveId < ActiveRecord::Migration
  def self.up
    change_column :users, :preferred_view, :string, :limit => 255, :default => :compact

    add_column :indicators, :parent_objective_id, :integer

    add_index :indicators, [:parent_objective_id]
  end

  def self.down
    change_column :users, :preferred_view, :string, default: "compact"

    remove_column :indicators, :parent_objective_id

    remove_index :indicators, :name => :index_indicators_on_parent_objective_id rescue ActiveRecord::StatementInvalid
  end
end
