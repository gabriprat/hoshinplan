class HoshinsCount < ActiveRecord::Migration
  def self.up
    rename_column :hoshins, :children_count, :hoshins_count
  end

  def self.down
    rename_column :hoshins, :hoshins_count, :children_count
  end
end
