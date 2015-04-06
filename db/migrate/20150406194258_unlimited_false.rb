class UnlimitedFalse < ActiveRecord::Migration
  def self.up
    change_column :users, :preferred_view, :string, :limit => 255, :default => :expanded

    change_column :companies, :unlimited, :boolean, :null => false, :default => false
  end

  def self.down
    change_column :users, :preferred_view, :string, default: "expanded"

    change_column :companies, :unlimited, :boolean, default: true, null: false
  end
end
