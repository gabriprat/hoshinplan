class Payments < ActiveRecord::Migration
  def self.up
    create_table :payments do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :user_id
    end
    add_index :payments, [:user_id]

    change_column :users, :preferred_view, :string, :limit => 255, :default => :expanded
  end

  def self.down
    change_column :users, :preferred_view, :string, default: "expanded"

    drop_table :payments
  end
end
