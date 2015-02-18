class AllowNullWorstValues < ActiveRecord::Migration
  def self.up
    change_column :users, :preferred_view, :string, :limit => 255, :default => :expanded

    change_column :indicators, :worst_value, :decimal, :null => true, :default => 0.0
  end

  def self.down
    change_column :users, :preferred_view, :string, default: "expanded"

    change_column :indicators, :worst_value, :decimal, default: 0.0,   null: false
  end
end
