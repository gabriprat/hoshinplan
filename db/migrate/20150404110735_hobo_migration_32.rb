class HoboMigration32 < ActiveRecord::Migration
  def self.up
    change_column :users, :preferred_view, :string, :limit => 255, :default => :expanded

    rename_column :paypal_buttons, :paypal_id, :id_paypal
    rename_column :paypal_buttons, :paypal_sandbox_id, :id_paypal_sandbox
  end

  def self.down
    change_column :users, :preferred_view, :string, default: "expanded"

    rename_column :paypal_buttons, :id_paypal, :paypal_id
    rename_column :paypal_buttons, :id_paypal_sandbox, :paypal_sandbox_id
  end
end
