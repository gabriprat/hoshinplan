class HoboMigration30 < ActiveRecord::Migration
  def self.up
    create_table :paypal_buttons do |t|
      t.string   :product, :id => true
      t.string   :paypal_id
      t.string   :paypal_sandbox_id
      t.datetime :created_at
      t.datetime :updated_at
    end

    change_column :users, :preferred_view, :string, :limit => 255, :default => :expanded
  end

  def self.down
    change_column :users, :preferred_view, :string, default: "expanded"

    drop_table :paypal_buttons
  end
end
