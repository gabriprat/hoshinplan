class BillingPlansWorkers < ActiveRecord::Migration
  def self.up
    change_column :users, :preferred_view, :string, :limit => 255, :default => :expanded

    add_column :billing_plans, :workers, :integer

    change_column :tasks, :feeling, :string, :limit => 255, :null => false, :default => :smile
  end

  def self.down
    change_column :users, :preferred_view, :string, default: "expanded"

    remove_column :billing_plans, :workers

    change_column :tasks, :feeling, :string, default: "smile",   null: false
  end
end
