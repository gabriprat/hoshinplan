class HoboMigration42 < ActiveRecord::Migration
  def self.up
    change_column :users, :preferred_view, :string, :limit => 255, :default => :expanded

    rename_column :payments, :txn_id, :token
    rename_column :payments, :gross, :amount_value
    add_column :payments, :amount_currency, :string
  end

  def self.down
    change_column :users, :preferred_view, :string, default: "expanded"

    rename_column :payments, :token, :txn_id
    rename_column :payments, :amount_value, :gross
    remove_column :payments, :amount_currency
  end
end
