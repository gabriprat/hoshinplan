class BetaAccessAndRailsUpgrade < ActiveRecord::Migration
  def self.up
    change_column :auth_providers, :email_domain, :string, :limit => nil, :null => false
    change_column :auth_providers, :type, :string, :limit => nil
    change_column :auth_providers, :openid_url, :string, :limit => nil
    change_column :auth_providers, :issuer, :string, :limit => nil
    change_column :auth_providers, :sso_url, :string, :limit => nil
    change_column :auth_providers, :fingerprint, :string, :limit => nil
    change_column :auth_providers, :id_format, :string, :limit => nil

    change_column :areas, :name, :string, :limit => nil, :null => false
    change_column :areas, :color, :string, :limit => nil

    add_column :users, :beta_access, :boolean
    change_column :users, :remember_token, :string, :limit => nil
    change_column :users, :name, :string, :limit => nil
    change_column :users, :email_address, :string, :limit => nil
    change_column :users, :administrator, :boolean, :default => false
    change_column :users, :state, :string, :limit => nil, :default => "inactive"
    change_column :users, :image_file_name, :string, :limit => nil
    change_column :users, :image_content_type, :string, :limit => nil
    change_column :users, :timezone, :string, :limit => nil
    change_column :users, :color, :string, :limit => nil
    change_column :users, :language, :string, :limit => nil
    change_column :users, :preferred_view, :string, :limit => nil, :default => :expanded
    change_column :users, :payments_count, :integer, :null => false, :default => 0
    change_column :users, :firstName, :string, :limit => nil
    change_column :users, :lastName, :string, :limit => nil

    change_column :hoshins, :name, :string, :limit => nil, :null => false, :default => "plan"
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
    change_column :hoshins, :state, :string, :limit => nil, :default => "active"
    change_column :hoshins, :color, :string, :limit => nil

    change_column :companies, :name, :string, :limit => nil
    change_column :companies, :hoshins_count, :integer, :null => false, :default => 0
    change_column :companies, :unlimited, :boolean, :null => false, :default => false

    change_column :billing_plans, :name, :string, :limit => nil
    change_column :billing_plans, :description, :string, :limit => nil
    change_column :billing_plans, :frequency, :string, :limit => nil
    change_column :billing_plans, :amount_currency, :string, :limit => nil
    change_column :billing_plans, :id_paypal, :string, :limit => nil
    change_column :billing_plans, :status_paypal, :string, :limit => nil
    change_column :billing_plans, :brief, :string, :limit => nil
    change_column :billing_plans, :css_class, :string, :limit => nil

    change_column :client_applications, :name, :string, :limit => nil
    change_column :client_applications, :description, :string, :limit => nil
    change_column :client_applications, :key, :string, :limit => nil
    change_column :client_applications, :secret, :string, :limit => nil

    change_column :goals, :name, :string, :limit => nil, :null => false

    change_column :indicators, :name, :string, :limit => nil, :null => false
    change_column :indicators, :frequency, :string, :limit => nil
    change_column :indicators, :goal, :decimal, :default => 100.0
    change_column :indicators, :reminder, :boolean, :null => false, :default => true
    change_column :indicators, :worst_value, :decimal, :default => 0.0
    change_column :indicators, :show_on_parent, :boolean, :null => false, :default => false
    change_column :indicators, :type, :string, :limit => nil
    change_column :indicators, :show_on_charts, :boolean, :null => false, :default => true

    change_column :objectives, :name, :string, :limit => nil, :null => false
    change_column :objectives, :neglected, :boolean, :default => false
    change_column :objectives, :blind, :boolean, :default => true

    change_column :logs, :title, :string, :limit => nil
    change_column :logs, :type, :string, :limit => nil
    change_column :logs, :operation, :string, :limit => nil, :null => false

    change_column :tasks, :name, :string, :limit => nil, :null => false
    change_column :tasks, :status, :string, :limit => nil, :default => "backlog"
    change_column :tasks, :type, :string, :limit => nil
    change_column :tasks, :reminder, :boolean, :default => true
    change_column :tasks, :lane_pos, :integer, :null => false, :default => 0
    change_column :tasks, :feeling, :string, :limit => nil, :null => false, :default => :smile

    change_column :payments, :token, :string, :limit => nil
    change_column :payments, :status, :string, :limit => nil
    change_column :payments, :amount_currency, :string, :limit => nil
    change_column :payments, :id_paypal, :string, :limit => nil

    change_column :user_companies, :state, :string, :limit => nil

    change_column :company_email_domains, :domain, :string, :limit => nil

    change_column :authorizations, :provider, :string, :limit => nil, :null => false
    change_column :authorizations, :uid, :string, :limit => nil, :null => false
    change_column :authorizations, :email_address, :string, :limit => nil
    change_column :authorizations, :name, :string, :limit => nil
    change_column :authorizations, :nickname, :string, :limit => nil
    change_column :authorizations, :location, :string, :limit => nil
    change_column :authorizations, :image, :string, :limit => nil
    change_column :authorizations, :phone, :string, :limit => nil

    change_column :paypal_buttons, :product, :string, :limit => nil
    change_column :paypal_buttons, :id_paypal, :string, :limit => nil
    change_column :paypal_buttons, :id_paypal_sandbox, :string, :limit => nil
  end

  def self.down
    change_column :auth_providers, :email_domain, :string, limit: 255, null: false
    change_column :auth_providers, :type, :string, limit: 255
    change_column :auth_providers, :openid_url, :string, limit: 255
    change_column :auth_providers, :issuer, :string, limit: 255
    change_column :auth_providers, :sso_url, :string, limit: 255
    change_column :auth_providers, :fingerprint, :string, limit: 255
    change_column :auth_providers, :id_format, :string, limit: 255

    change_column :areas, :name, :string, limit: 255, null: false
    change_column :areas, :color, :string, limit: 255

    remove_column :users, :beta_access
    change_column :users, :remember_token, :string, limit: 255
    change_column :users, :name, :string, limit: 255
    change_column :users, :email_address, :string, limit: 255
    change_column :users, :administrator, :boolean, default: false
    change_column :users, :state, :string, limit: 255, default: "inactive"
    change_column :users, :image_file_name, :string, limit: 255
    change_column :users, :image_content_type, :string, limit: 255
    change_column :users, :timezone, :string, limit: 255
    change_column :users, :color, :string, limit: 255
    change_column :users, :language, :string, limit: 255
    change_column :users, :preferred_view, :string, limit: 255, default: "expanded"
    change_column :users, :payments_count, :integer, default: 0,          null: false
    change_column :users, :firstName, :string, limit: 255
    change_column :users, :lastName, :string, limit: 255

    change_column :hoshins, :name, :string, limit: 255, default: "plan",   null: false
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
    change_column :hoshins, :state, :string, limit: 255, default: "active"
    change_column :hoshins, :color, :string, limit: 255

    change_column :companies, :name, :string, limit: 255
    change_column :companies, :hoshins_count, :integer, default: 0,     null: false
    change_column :companies, :unlimited, :boolean, default: false, null: false

    change_column :billing_plans, :name, :string, limit: 255
    change_column :billing_plans, :description, :string, limit: 255
    change_column :billing_plans, :frequency, :string, limit: 255
    change_column :billing_plans, :amount_currency, :string, limit: 255
    change_column :billing_plans, :id_paypal, :string, limit: 255
    change_column :billing_plans, :status_paypal, :string, limit: 255
    change_column :billing_plans, :brief, :string, limit: 255
    change_column :billing_plans, :css_class, :string, limit: 255

    change_column :client_applications, :name, :string, limit: 255
    change_column :client_applications, :description, :string, limit: 255
    change_column :client_applications, :key, :string, limit: 255
    change_column :client_applications, :secret, :string, limit: 255

    change_column :goals, :name, :string, limit: 255, null: false

    change_column :indicators, :name, :string, limit: 255,                 null: false
    change_column :indicators, :frequency, :string, limit: 255
    change_column :indicators, :goal, :decimal, default: 100.0
    change_column :indicators, :reminder, :boolean, default: true,  null: false
    change_column :indicators, :worst_value, :decimal, default: 0.0
    change_column :indicators, :show_on_parent, :boolean, default: false, null: false
    change_column :indicators, :type, :string, limit: 255
    change_column :indicators, :show_on_charts, :boolean, default: true,  null: false

    change_column :objectives, :name, :string, limit: 255,                 null: false
    change_column :objectives, :neglected, :boolean, default: false
    change_column :objectives, :blind, :boolean, default: true

    change_column :logs, :title, :string, limit: 255
    change_column :logs, :type, :string, limit: 255
    change_column :logs, :operation, :string, limit: 255, null: false

    change_column :tasks, :name, :string, limit: 255,                     null: false
    change_column :tasks, :status, :string, limit: 255, default: "backlog"
    change_column :tasks, :type, :string, limit: 255
    change_column :tasks, :reminder, :boolean, default: true
    change_column :tasks, :lane_pos, :integer, default: 0,         null: false
    change_column :tasks, :feeling, :string, limit: 255, default: "smile",   null: false

    change_column :payments, :token, :string, limit: 255
    change_column :payments, :status, :string, limit: 255
    change_column :payments, :amount_currency, :string, limit: 255
    change_column :payments, :id_paypal, :string, limit: 255

    change_column :user_companies, :state, :string, limit: 255

    change_column :company_email_domains, :domain, :string, limit: 255

    change_column :authorizations, :provider, :string, limit: 255, null: false
    change_column :authorizations, :uid, :string, limit: 255, null: false
    change_column :authorizations, :email_address, :string, limit: 255
    change_column :authorizations, :name, :string, limit: 255
    change_column :authorizations, :nickname, :string, limit: 255
    change_column :authorizations, :location, :string, limit: 255
    change_column :authorizations, :image, :string, limit: 255
    change_column :authorizations, :phone, :string, limit: 255

    change_column :paypal_buttons, :product, :string, limit: 255
    change_column :paypal_buttons, :id_paypal, :string, limit: 255
    change_column :paypal_buttons, :id_paypal_sandbox, :string, limit: 255
  end
end
