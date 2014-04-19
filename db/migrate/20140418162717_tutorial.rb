class Tutorial < ActiveRecord::Migration
  def self.up
    add_column :users, :tutorial_step, :decimal

    add_column :hoshins, :objectives_count, :integer, :default => 0, :null => false
  end

  def self.down
    remove_column :users, :tutorial_step

    remove_column :hoshins, :objectives_count
  end
end
