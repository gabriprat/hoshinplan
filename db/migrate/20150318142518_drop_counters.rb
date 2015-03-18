class DropCounters < ActiveRecord::Migration
  def self.up
    remove_column :areas, :objectives_count
    remove_column :areas, :indicators_count
    remove_column :areas, :tasks_count

    change_column :users, :preferred_view, :string, :limit => 255, :default => :expanded

    remove_column :objectives, :indicators_count
    remove_column :objectives, :tasks_count
  end

  def self.down
    add_column :areas, :objectives_count, :integer, default: 0, null: false
    add_column :areas, :indicators_count, :integer, default: 0, null: false
    add_column :areas, :tasks_count, :integer, default: 0, null: false

    change_column :users, :preferred_view, :string, default: "expanded"

    add_column :objectives, :indicators_count, :integer, default: 0, null: false
    add_column :objectives, :tasks_count, :integer, default: 0, null: false
  end
end
