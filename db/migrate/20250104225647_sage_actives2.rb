class SageActives2 < ActiveRecord::Migration
  def self.up
    create_table :sage_active_countries, id: false, primary_key: :id do |t|
      t.string   :id, null: false
      t.string   :name, null: false
      t.string   :iso_code_alpha2, null: false
      t.string   :iso_code_alpha3, null: false
      t.string   :iso_number, null: false
      t.string   :legislation_country_code
      t.string   :vies_code
      t.datetime :creationDate, null: false
      t.datetime :modificationDate, null: false
    end

    execute "ALTER TABLE sage_active_countries ADD PRIMARY KEY (id);" 
    add_index :sage_active_countries, [:iso_code_alpha2], :unique => true

    add_column :invoices, :sage_active_invoice_id, :string

    change_column :companies, :hoshins_count, :integer, :null => false, :default => 0
    change_column :companies, :unlimited, :boolean, :null => false, :default => false
    change_column :companies, :subscriptions_count, :integer, :null => false, :default => 0
    change_column :companies, :credit, :decimal, :precision => 8, :scale => 2, :default => 0

    change_column :users, :administrator, :boolean, :default => false
    change_column :users, :preferred_view, :string, :default => :expanded
    change_column :users, :subscriptions_count, :integer, :null => false, :default => 0
    change_column :users, :news, :boolean, :default => false
    change_column :users, :from_invitation, :boolean, :default => false
    change_column :users, :initial_task_state, :string, :null => false, :default => :backlog
    change_column :users, :companies_trial_days, :integer, :default => 0

    change_column :partners, :companies_trial_days, :integer, :default => 90

    change_column :objectives, :neglected, :boolean, :default => false
    change_column :objectives, :blind, :boolean, :default => true
    change_column :objectives, :hidden, :boolean, :null => false, :default => false

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
    change_column :hoshins, :tasks_visible_days, :integer, :null => false, :default => 110

    change_column :indicators, :goal, :decimal, :default => 100.0
    change_column :indicators, :reminder, :boolean, :null => false, :default => true
    change_column :indicators, :worst_value, :decimal, :default => 0.0
    change_column :indicators, :show_on_parent, :boolean, :null => false, :default => false
    change_column :indicators, :show_on_charts, :boolean, :null => false, :default => true
    change_column :indicators, :hidden, :boolean, :null => false, :default => false

    change_column :user_companies, :roles_mask, :integer, :null => false, :default => 7

    change_column :tasks, :reminder, :boolean, :default => true
    change_column :tasks, :lane_pos, :integer, :null => false, :default => 0
    change_column :tasks, :feeling, :string, :null => false, :default => :smile
    change_column :tasks, :visible_days, :integer, :null => false, :default => 110
    change_column :tasks, :hidden, :boolean, :null => false, :default => false

    change_column :subscriptions, :per_user, :boolean, :null => false, :default => true

    add_column :billing_details, :sage_active_third_party_id, :string
    change_column :billing_details, :vies_valid, :boolean, :default => false

    change_column :billing_plans, :min_users, :integer, :null => false, :default => 5
  end

  def self.down
    remove_column :invoices, :sage_active_invoice_id

    change_column :companies, :hoshins_count, :integer, default: 0,     null: false
    change_column :companies, :unlimited, :boolean, default: false, null: false
    change_column :companies, :subscriptions_count, :integer, default: 0,     null: false
    change_column :companies, :credit, :decimal, precision: 8, scale: 2, default: 0.0

    change_column :users, :administrator, :boolean, default: false
    change_column :users, :preferred_view, :string, default: "expanded"
    change_column :users, :subscriptions_count, :integer, default: 0,          null: false
    change_column :users, :news, :boolean, default: false
    change_column :users, :from_invitation, :boolean, default: false
    change_column :users, :initial_task_state, :string, default: "backlog",  null: false
    change_column :users, :companies_trial_days, :integer, default: 0

    change_column :partners, :companies_trial_days, :integer, default: 90

    change_column :objectives, :neglected, :boolean, default: false
    change_column :objectives, :blind, :boolean, default: true
    change_column :objectives, :hidden, :boolean, default: false, null: false

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
    change_column :hoshins, :tasks_visible_days, :integer, default: 110,      null: false

    change_column :indicators, :goal, :decimal, default: 100.0
    change_column :indicators, :reminder, :boolean, default: true,  null: false
    change_column :indicators, :worst_value, :decimal, default: 0.0
    change_column :indicators, :show_on_parent, :boolean, default: false, null: false
    change_column :indicators, :show_on_charts, :boolean, default: true,  null: false
    change_column :indicators, :hidden, :boolean, default: false, null: false

    change_column :user_companies, :roles_mask, :integer, default: 7, null: false

    change_column :tasks, :reminder, :boolean, default: true
    change_column :tasks, :lane_pos, :integer, default: 0,         null: false
    change_column :tasks, :feeling, :string, default: "smile",   null: false
    change_column :tasks, :visible_days, :integer, default: 110,       null: false
    change_column :tasks, :hidden, :boolean, default: false,     null: false

    change_column :subscriptions, :per_user, :boolean, default: true,     null: false

    remove_column :billing_details, :sage_active_third_party_id
    change_column :billing_details, :vies_valid, :boolean, default: false

    change_column :billing_plans, :min_users, :integer, default: 5, null: false

    drop_table :sage_active_countries
  end
end
