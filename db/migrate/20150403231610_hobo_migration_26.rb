class HoboMigration26 < ActiveRecord::Migration
  def self.up
    change_column :users, :preferred_view, :string, :limit => 255, :default => :expanded

    add_column :payments, :txn_id, :string

    add_index :payments, [:txn_id], :unique => true
  end

  def self.down
    change_column :users, :preferred_view, :string, default: "expanded"

    remove_column :payments, :txn_id

    remove_index :payments, :name => :index_payments_on_txn_id rescue ActiveRecord::StatementInvalid
  end
end
