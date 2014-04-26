class LanePos < ActiveRecord::Migration
  def self.up
    change_column :indicators, :goal, :decimal, :null => true, :default => 100.0

    add_column :tasks, :lane_pos, :integer

  end

  def self.down
    change_column :indicators, :goal, :decimal, :default => 100.0, :null => false

    remove_column :tasks, :lane_pos

  end
end
