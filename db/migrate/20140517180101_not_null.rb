class NotNull < ActiveRecord::Migration
  def self.up
    change_column :tasks, :lane_pos, :integer, :null => false, :default => 0

    change_column :hoshins, :name, :string, :limit => 255, :null => false, :default => "plan"
  end

  def self.down
    change_column :tasks, :lane_pos, :integer

    change_column :hoshins, :name, :string
  end
end
