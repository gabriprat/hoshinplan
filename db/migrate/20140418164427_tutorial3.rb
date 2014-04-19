class Tutorial3 < ActiveRecord::Migration
  def self.up
    add_column :users, :tutorial_step, :decimal
  end

  def self.down
    remove_column :users, :tutorial_step
  end
end
