class Tutorial4 < ActiveRecord::Migration
  def self.up
    change_column :users, :tutorial_step, :integer
  end

  def self.down
    change_column :users, :tutorial_step, :decimal
  end
end
