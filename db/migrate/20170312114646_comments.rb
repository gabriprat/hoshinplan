class Comments < ActiveRecord::Migration
  def self.up
    create_table :generic_comments do |t|
      t.text     :body
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :company_id, :null => false
      t.integer  :creator_id
      t.integer  :hoshin_id
      t.integer  :area_id
      t.integer  :goal_id
      t.integer  :objective_id
      t.integer  :indicator_id
      t.string   :type
      t.integer  :task_id
    end
    add_index :generic_comments, [:company_id]
    add_index :generic_comments, [:creator_id]
    add_index :generic_comments, [:type]
    add_index :generic_comments, [:company_id, :created_at]
    add_index :generic_comments, [:hoshin_id]
    add_index :generic_comments, [:hoshin_id, :created_at]
    add_index :generic_comments, [:area_id]
    add_index :generic_comments, [:area_id, :created_at]
    add_index :generic_comments, [:goal_id]
    add_index :generic_comments, [:goal_id, :created_at]
    add_index :generic_comments, [:objective_id]
    add_index :generic_comments, [:objective_id, :created_at]
    add_index :generic_comments, [:indicator_id]
    add_index :generic_comments, [:indicator_id, :created_at]
    add_index :generic_comments, [:task_id]
    add_index :generic_comments, [:task_id, :created_at]

    change_column :users, :administrator, :boolean, :default => false
    change_column :users, :preferred_view, :string, :default => :expanded
    change_column :users, :subscriptions_count, :integer, :null => false, :default => 0
    change_column :users, :news, :boolean, :default => true
    change_column :users, :from_invitation, :boolean, :default => false
    change_column :users, :initial_task_state, :string, :null => false, :default => :backlog
    change_column :users, :companies_trial_days, :integer, :default => 0

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

    change_column :subscriptions, :per_user, :boolean, :null => false, :default => true

    change_column :user_companies, :roles_mask, :integer, :null => false, :default => 7
  end

  def self.down
    change_column :users, :administrator, :boolean, default: false
    change_column :users, :preferred_view, :string, default: "expanded"
    change_column :users, :subscriptions_count, :integer, default: 0,          null: false
    change_column :users, :news, :boolean, default: true
    change_column :users, :from_invitation, :boolean, default: false
    change_column :users, :initial_task_state, :string, default: "backlog",  null: false
    change_column :users, :companies_trial_days, :integer, default: 0

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

    change_column :subscriptions, :per_user, :boolean, default: true,     null: false

    change_column :user_companies, :roles_mask, :integer, default: 7, null: false

    drop_table :generic_comments
  end
end
