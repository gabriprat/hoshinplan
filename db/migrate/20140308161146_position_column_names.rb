class PositionColumnNames < ActiveRecord::Migration
  def self.up
    rename_column :indicators, :position, :ind_pos

    rename_column :objectives, :position, :obj_pos

    rename_column :tasks, :position, :tsk_pos
  end

  def self.down
    rename_column :indicators, :ind_pos, :position

    rename_column :objectives, :obj_pos, :position

    rename_column :tasks, :tsk_pos, :position
  end
end
