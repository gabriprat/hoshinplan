class Tutorial2 < ActiveRecord::Migration
  def self.up
    remove_column :users, :tutorial_step
  end

  def self.down
    add_column :users, :tutorial_step, :decimal
  end
end
