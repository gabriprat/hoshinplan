class BillingPlans < ActiveRecord::Migration
  def self.up
    create_table :billing_plans do |t|
      t.string   :name
      t.string   :description
      t.text     :features
      t.string   :frequency
      t.integer  :interval
      t.string   :amount_currency
      t.decimal  :amount_value, :precision => 8, :scale => 2
      t.datetime :created_at
      t.datetime :updated_at
    end

    change_column :users, :preferred_view, :string, :limit => 255, :default => :expanded
  end

  def self.down
    change_column :users, :preferred_view, :string, default: "expanded"

    drop_table :billing_plans
  end
end
