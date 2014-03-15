class ChildKpi < ActiveRecord::Migration
  def self.up
    add_column :indicators, :show_on_parent, :boolean
    add_column :indicators, :type, :string

    add_index :indicators, [:type]
  end

  def self.down
    remove_column :indicators, :show_on_parent
    remove_column :indicators, :type

    remove_index :indicators, :name => :index_indicators_on_type rescue ActiveRecord::StatementInvalid
  end
end
