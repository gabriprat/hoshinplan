class HealthUpdatedAt < ActiveRecord::Migration
  def self.up
    change_column :users, :preferred_view, :string, :limit => 255, :default => :expanded

    add_column :hoshins, :health_updated_at, :datetime
  end

  def self.down
    change_column :users, :preferred_view, :string, default: "expanded"

    remove_column :hoshins, :health_updated_at
  end
end
