class Unlimited < ActiveRecord::Migration
  def self.up
    change_column :users, :preferred_view, :string, :limit => 255, :default => :expanded

    add_column :companies, :unlimited, :boolean, :default => true, :null => false
    remove_column :companies, :plan
  end

  def self.down
    change_column :users, :preferred_view, :string, default: "expanded"

    remove_column :companies, :unlimited
    add_column :companies, :plan, :string, default: "basic"
  end
end
