class AddWorstValue < ActiveRecord::Migration
  def self.up
    add_column :indicators, :worst_value, :decimal, :default => 0.0
  end

  def self.down
    remove_column :indicators, :worst_value
  end
end
