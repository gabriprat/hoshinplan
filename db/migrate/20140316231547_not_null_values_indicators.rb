class NotNullValuesIndicators < ActiveRecord::Migration
  def self.up
    change_column :indicators, :goal, :decimal, :null => false, :default => 100.0
    change_column :indicators, :reminder, :boolean, :null => false, :default => true
    change_column :indicators, :worst_value, :decimal, :null => false, :default => 0.0
    change_column :indicators, :show_on_parent, :boolean, :null => false, :default => false
  end

  def self.down
    change_column :indicators, :goal, :decimal, :default => 100.0
    change_column :indicators, :reminder, :boolean, :default => true
    change_column :indicators, :worst_value, :decimal, :default => 0.0
    change_column :indicators, :show_on_parent, :boolean
  end
end
