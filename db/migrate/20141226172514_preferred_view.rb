class PreferredView < ActiveRecord::Migration
  def self.up
    add_column :users, :preferred_view, :string, :default => :expanded
  end

  def self.down
    remove_column :users, :preferred_view
  end
end
