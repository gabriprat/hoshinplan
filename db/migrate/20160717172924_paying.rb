class Paying < ActiveRecord::Migration
  def self.up
    change_column :users, :administrator, :boolean, :default => false
    change_column :users, :preferred_view, :string, :default => :expanded
    change_column :users, :subscriptions_count, :integer, :null => false, :default => 0
    change_column :users, :news, :boolean, :default => true
    change_column :users, :from_invitation, :boolean, :default => false
    change_column :users, :initial_task_state, :string, :null => false, :default => :backlog

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

    change_column :companies, :hoshins_count, :integer, :null => false, :default => 0
    change_column :companies, :unlimited, :boolean, :null => false, :default => false
    change_column :companies, :subscriptions_count, :integer, :null => false, :default => 0
    change_column :companies, :credit, :decimal, :precision => 8, :scale => 2, :default => 0

    change_column :billing_details, :vies_valid, :boolean, :default => false

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
    change_column :tasks, :visible_days, :integer, :null => false, :default => 110

    add_column :subscriptions, :paying_at, :datetime
    add_column :subscriptions, :payment_error, :string

    change_column :user_companies, :roles_mask, :integer, :null => false, :default => 3
  end

  def self.down
    change_column :users, :administrator, :boolean, default: false
    change_column :users, :preferred_view, :string, default: "expanded"
    change_column :users, :subscriptions_count, :integer, default: 0,          null: false
    change_column :users, :news, :boolean, default: true
    change_column :users, :from_invitation, :boolean, default: false
    change_column :users, :initial_task_state, :string, default: "backlog",  null: false

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

    change_column :companies, :hoshins_count, :integer, default: 0,     null: false
    change_column :companies, :unlimited, :boolean, default: false, null: false
    change_column :companies, :subscriptions_count, :integer, default: 0,     null: false
    change_column :companies, :credit, :decimal, precision: 8, scale: 2, default: 0.0

    change_column :billing_details, :vies_valid, :boolean, default: false

    change_column :indicators, :goal, :decimal, default: 100.0
    change_column :indicators, :reminder, :boolean, default: true,  null: false
    change_column :indicators, :worst_value, :decimal, default: 0.0
    change_column :indicators, :show_on_parent, :boolean, default: false, null: false
    change_column :indicators, :show_on_charts, :boolean, default: true,  null: false

    change_column :objectives, :neglected, :boolean, default: false
    change_column :objectives, :blind, :boolean, default: true

    change_column :tasks, :reminder, :boolean, default: true
    change_column :tasks, :lane_pos, :integer, default: 0,         null: false
    change_column :tasks, :feeling, :string, default: "smile",   null: false
    change_column :tasks, :visible_days, :integer, default: 110,       null: false

    remove_column :subscriptions, :paying_at
    remove_column :subscriptions, :payment_error

    change_column :user_companies, :roles_mask, :integer, default: 3, null: false
  end
end
