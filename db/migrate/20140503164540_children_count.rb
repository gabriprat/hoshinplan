class ChildrenCount < ActiveRecord::Migration
  def self.up
    add_column :hoshins, :children_count, :integer, :default => 0, :null => false
  end

  def self.down
    remove_column :hoshins, :children_count
  end
end
