class Remainders < ActiveRecord::Migration
  def self.up
    add_column :indicators, :reminder, :boolean, :default => true

    add_column :tasks, :reminder, :boolean, :default => true
  end

  def self.down
    remove_column :indicators, :reminder

    remove_column :tasks, :reminder
  end
end
