class IndicatorParentAreaId < ActiveRecord::Migration
  def self.up
    change_column :users, :preferred_view, :string, :limit => 255, :default => :compact

    add_column :indicators, :parent_area_id, :integer

    add_index :indicators, [:parent_area_id]
  end

  def self.down
    change_column :users, :preferred_view, :string, default: "compact"

    remove_column :indicators, :parent_area_id

    remove_index :indicators, :name => :index_indicators_on_parent_area_id rescue ActiveRecord::StatementInvalid
  end
end
