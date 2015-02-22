class LastSeenAt < ActiveRecord::Migration
  def self.up
    add_column :users, :last_seen_at, :date
    change_column :users, :preferred_view, :string, :limit => 255, :default => :expanded
  end

  def self.down
    remove_column :users, :last_seen_at
    change_column :users, :preferred_view, :string, default: "expanded"
  end
end
