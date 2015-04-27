class HoboMigration47 < ActiveRecord::Migration
  def self.up
    change_column :users, :preferred_view, :string, :limit => 255, :default => :compact

    rename_column :objectives, :negleted, :neglected
  end

  def self.down
    change_column :users, :preferred_view, :string, default: "compact"

    rename_column :objectives, :neglected, :negleted
  end
end
