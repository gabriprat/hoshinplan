class Histories < ActiveRecord::Migration
  def self.up
    add_column :indicator_histories, :day, :date
  end

  def self.down
    remove_column :indicator_histories, :day
  end
end
