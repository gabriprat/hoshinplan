class RenamePaymentsSubscriptions < ActiveRecord::Migration
  def self.up
    remove_index :payments, :name => :index_payments_on_billing_plan_id rescue ActiveRecord::StatementInvalid
    remove_index :payments, :name => :index_payments_on_company_id rescue ActiveRecord::StatementInvalid
    remove_index :payments, :name => :index_payments_on_deleted_at rescue ActiveRecord::StatementInvalid
    remove_index :payments, :name => :index_payments_on_token rescue ActiveRecord::StatementInvalid
    remove_index :payments, :name => :index_payments_on_user_id rescue ActiveRecord::StatementInvalid
    
    rename_table :payments, :subscriptions

    rename_column :users, :payments_count, :subscriptions_count
    change_column :users, :administrator, :boolean, :default => false
    change_column :users, :preferred_view, :string, :default => :expanded
    change_column :users, :news, :boolean, :default => true
    change_column :users, :subscriptions_count, :integer, :null => false, :default => 0

    change_column :hoshins, :areas_count, :integer, :null => false, :default => 0
    change_column :hoshins, :objectives_count, :integer, :null => false, :default => 0
    change_column :hoshins, :goals_count, :integer, :null => false, :default => 0
    change_column :hoshins, :indicators_count, :integer, :null => false, :default => 0
    change_column :hoshins, :tasks_count, :integer, :null => false, :default => 0
    change_column :hoshins, :outdated_indicators_count, :integer, :null => false, :default => 0
    change_column :hoshins, :outdated_tasks_count, :integer, :null => false, :default => 0
    change_column :hoshins, :blind_objectives_count, :integer, :null => false, :default => 0
    change_column :hoshins, :neglected_objectives_count, :integer, :null => false, :default => 0
    change_column :hoshins, :hoshins_count, :integer, :null => false, :default => 0

    change_column :companies, :hoshins_count, :integer, :null => false, :default => 0
    change_column :companies, :unlimited, :boolean, :null => false, :default => false

    change_column :indicators, :goal, :decimal, :default => 100.0
    change_column :indicators, :reminder, :boolean, :null => false, :default => true
    change_column :indicators, :worst_value, :decimal, :default => 0.0
    change_column :indicators, :show_on_parent, :boolean, :null => false, :default => false
    change_column :indicators, :show_on_charts, :boolean, :null => false, :default => true

    change_column :objectives, :neglected, :boolean, :default => false
    change_column :objectives, :blind, :boolean, :default => true

    change_column :tasks, :reminder, :boolean, :default => true
    change_column :tasks, :lane_pos, :integer, :null => false, :default => 0
    change_column :tasks, :feeling, :string, :null => false, :default => :smile

    add_index :subscriptions, [:token], :unique => true
    add_index :subscriptions, [:deleted_at]
    add_index :subscriptions, [:user_id]
    add_index :subscriptions, [:company_id]
    add_index :subscriptions, [:billing_plan_id]
  end

  def self.down
    rename_column :users, :subscriptions_count, :payments_count
    change_column :users, :administrator, :boolean, default: false
    change_column :users, :preferred_view, :string, default: "expanded"
    change_column :users, :news, :boolean, default: true
    change_column :users, :payments_count, :integer, default: 0,          null: false

    change_column :hoshins, :areas_count, :integer, default: 0,        null: false
    change_column :hoshins, :objectives_count, :integer, default: 0,        null: false
    change_column :hoshins, :goals_count, :integer, default: 0,        null: false
    change_column :hoshins, :indicators_count, :integer, default: 0,        null: false
    change_column :hoshins, :tasks_count, :integer, default: 0,        null: false
    change_column :hoshins, :outdated_indicators_count, :integer, default: 0,        null: false
    change_column :hoshins, :outdated_tasks_count, :integer, default: 0,        null: false
    change_column :hoshins, :blind_objectives_count, :integer, default: 0,        null: false
    change_column :hoshins, :neglected_objectives_count, :integer, default: 0,        null: false
    change_column :hoshins, :hoshins_count, :integer, default: 0,        null: false

    change_column :companies, :hoshins_count, :integer, default: 0,     null: false
    change_column :companies, :unlimited, :boolean, default: false, null: false

    change_column :indicators, :goal, :decimal, default: 100.0
    change_column :indicators, :reminder, :boolean, default: true,  null: false
    change_column :indicators, :worst_value, :decimal, default: 0.0
    change_column :indicators, :show_on_parent, :boolean, default: false, null: false
    change_column :indicators, :show_on_charts, :boolean, default: true,  null: false

    change_column :objectives, :neglected, :boolean, default: false
    change_column :objectives, :blind, :boolean, default: true

    change_column :tasks, :reminder, :boolean, default: true
    change_column :tasks, :lane_pos, :integer, default: 0,        null: false
    change_column :tasks, :feeling, :string, default: "smile",  null: false

    remove_index :subscriptions, :name => :index_subscriptions_on_token rescue ActiveRecord::StatementInvalid
    remove_index :subscriptions, :name => :index_subscriptions_on_deleted_at rescue ActiveRecord::StatementInvalid
    remove_index :subscriptions, :name => :index_subscriptions_on_user_id rescue ActiveRecord::StatementInvalid
    remove_index :subscriptions, :name => :index_subscriptions_on_company_id rescue ActiveRecord::StatementInvalid
    remove_index :subscriptions, :name => :index_subscriptions_on_billing_plan_id rescue ActiveRecord::StatementInvalid

    rename_table :subscriptions, :payments

    add_index :payments, [:billing_plan_id]
    add_index :payments, [:company_id]
    add_index :payments, [:deleted_at]
    add_index :payments, [:token], :unique => true
    add_index :payments, [:user_id]
  end
end
