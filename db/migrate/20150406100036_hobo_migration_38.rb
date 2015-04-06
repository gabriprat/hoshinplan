class HoboMigration38 < ActiveRecord::Migration
  def self.up
    change_column :users, :preferred_view, :string, :limit => 255, :default => :expanded

    add_column :billing_plans, :status_paypal, :string
  end

  def self.down
    change_column :users, :preferred_view, :string, default: "expanded"

    remove_column :billing_plans, :status_paypal
  end
end
