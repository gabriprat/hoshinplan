class HoboMigration31 < ActiveRecord::Migration
  def self.up
    change_column :users, :preferred_view, :string, :limit => 255, :default => :expanded

    add_index :paypal_buttons, [:product], :unique => true
  end

  def self.down
    change_column :users, :preferred_view, :string, default: "expanded"

    remove_index :paypal_buttons, :name => :index_paypal_buttons_on_product rescue ActiveRecord::StatementInvalid
  end
end
