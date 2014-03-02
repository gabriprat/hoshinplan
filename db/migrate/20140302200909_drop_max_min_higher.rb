class DropMaxMinHigher < ActiveRecord::Migration
  def self.up
    remove_column :indicators, :higher
    remove_column :indicators, :max_value
    remove_column :indicators, :min_value
  end

  def self.down
    add_column :indicators, :higher, :boolean, :default => true
    add_column :indicators, :max_value, :decimal, :default => 100.0
    add_column :indicators, :min_value, :decimal, :default => 0.0
  end
end
