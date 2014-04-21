class Health < ActiveRecord::Migration
  def self.up
    add_column :hoshins, :outdated_indicators_count, :integer, :default => 0, :null => false
    add_column :hoshins, :outdated_tasks_count, :integer, :default => 0, :null => false
    add_column :hoshins, :blind_objectives_count, :integer, :default => 0, :null => false
    add_column :hoshins, :neglected_objectives_count, :integer, :default => 0, :null => false
  end

  def self.down
    remove_column :hoshins, :outdated_indicators_count
    remove_column :hoshins, :outdated_tasks_count
    remove_column :hoshins, :blind_objectives_count
    remove_column :hoshins, :neglected_objectives_count
  end
end
