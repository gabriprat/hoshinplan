class MoreBillingDetails < ActiveRecord::Migration
  def self.up
    remove_column :users, :stripe_id
    change_column :users, :administrator, :boolean, :default => false
    change_column :users, :preferred_view, :string, :default => :expanded
    change_column :users, :subscriptions_count, :integer, :null => false, :default => 0
    change_column :users, :news, :boolean, :default => true
    change_column :users, :from_invitation, :boolean, :default => false

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
    change_column :companies, :subscriptions_count, :integer, :null => false, :default => 0

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

    rename_column :billing_details, :address, :address_line_1
    add_column :billing_details, :address_line_2, :string
    add_column :billing_details, :city, :string
    add_column :billing_details, :state, :string
    add_column :billing_details, :zip, :string
    add_column :billing_details, :stripe_client_id, :string
    add_column :billing_details, :card_brand, :string
    add_column :billing_details, :card_last4, :string
    add_column :billing_details, :card_exp_month, :integer
    add_column :billing_details, :card_exp_year, :integer
    add_column :billing_details, :card_stripe_token, :string
    add_column :billing_details, :creator_id, :integer
    add_column :billing_details, :company_id, :integer

    add_index :billing_details, [:creator_id]
    add_index :billing_details, [:company_id]
  end

  def self.down
    add_column :users, :stripe_id, :string
    change_column :users, :administrator, :boolean, default: false
    change_column :users, :preferred_view, :string, default: "expanded"
    change_column :users, :subscriptions_count, :integer, default: 0,          null: false
    change_column :users, :news, :boolean, default: true
    change_column :users, :from_invitation, :boolean, default: false

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
    change_column :companies, :subscriptions_count, :integer, default: 0,     null: false

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

    rename_column :billing_details, :address_line_1, :address
    remove_column :billing_details, :address_line_2
    remove_column :billing_details, :city
    remove_column :billing_details, :state
    remove_column :billing_details, :zip
    remove_column :billing_details, :stripe_client_id
    remove_column :billing_details, :card_brand
    remove_column :billing_details, :card_last4
    remove_column :billing_details, :card_exp_month
    remove_column :billing_details, :card_exp_year
    remove_column :billing_details, :card_stripe_token
    remove_column :billing_details, :creator_id
    remove_column :billing_details, :company_id

    remove_index :billing_details, :name => :index_billing_details_on_creator_id rescue ActiveRecord::StatementInvalid
    remove_index :billing_details, :name => :index_billing_details_on_company_id rescue ActiveRecord::StatementInvalid
  end
end
