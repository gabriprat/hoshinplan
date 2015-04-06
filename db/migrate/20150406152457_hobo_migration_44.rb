class HoboMigration44 < ActiveRecord::Migration
  def self.up
    change_column :users, :preferred_view, :string, :limit => 255, :default => :expanded

    add_column :payments, :billing_plan_id, :integer
    remove_column :payments, :product

    add_index :payments, [:billing_plan_id]
  end

  def self.down
    change_column :users, :preferred_view, :string, default: "expanded"

    remove_column :payments, :billing_plan_id
    add_column :payments, :product, :string

    remove_index :payments, :name => :index_payments_on_billing_plan_id rescue ActiveRecord::StatementInvalid
  end
end
