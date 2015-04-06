class HoboMigration37 < ActiveRecord::Migration
  def self.up
    change_column :users, :preferred_view, :string, :limit => 255, :default => :expanded

    add_column :billing_plans, :id_paypal, :string
  end

  def self.down
    change_column :users, :preferred_view, :string, default: "expanded"

    remove_column :billing_plans, :id_paypal
  end
end
