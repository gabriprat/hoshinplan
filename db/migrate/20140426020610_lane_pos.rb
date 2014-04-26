class LanePos < ActiveRecord::Migration
  def self.up
    change_column :indicators, :goal, :decimal, :null => true, :default => 100.0

    add_column :tasks, :lane_pos, :integer

    remove_index :indicator_histories, :name => :index_indicator_histories_on_indicator_id_and_day rescue ActiveRecord::StatementInvalid
  end

  def self.down
    change_column :indicators, :goal, :decimal, :default => 100.0, :null => false

    remove_column :tasks, :lane_pos

    add_index :indicator_histories, [:indicator_id, :day]
  end
end
