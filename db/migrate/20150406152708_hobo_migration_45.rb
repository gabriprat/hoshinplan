class HoboMigration45 < ActiveRecord::Migration
  def self.up
    change_column :users, :preferred_view, :string, :limit => 255, :default => :expanded

    add_column :billing_plans, :users, :integer
  end

  def self.down
    change_column :users, :preferred_view, :string, default: "expanded"

    remove_column :billing_plans, :users
  end
end
