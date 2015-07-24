class AddParanoia < ActiveRecord::Migration
  def self.up
    add_column :areas, :deleted_at, :datetime

    change_column :users, :preferred_view, :string, :limit => 255, :default => :expanded

    add_column :hoshins, :deleted_at, :datetime

    add_column :companies, :deleted_at, :datetime

    add_column :client_applications, :deleted_at, :datetime

    add_column :goals, :deleted_at, :datetime

    add_column :indicators, :deleted_at, :datetime

    add_column :objectives, :deleted_at, :datetime

    add_column :payments, :deleted_at, :datetime

    add_column :tasks, :deleted_at, :datetime
    change_column :tasks, :feeling, :string, :limit => 255, :null => false, :default => :smile

    add_index :areas, [:deleted_at]

    add_index :hoshins, [:deleted_at]

    add_index :companies, [:deleted_at]

    add_index :client_applications, [:deleted_at]

    add_index :goals, [:deleted_at]

    add_index :indicators, [:deleted_at]

    add_index :objectives, [:deleted_at]

    add_index :payments, [:deleted_at]

    add_index :tasks, [:deleted_at]
  end

  def self.down
    remove_column :areas, :deleted_at

    change_column :users, :preferred_view, :string, default: "expanded"

    remove_column :hoshins, :deleted_at

    remove_column :companies, :deleted_at

    remove_column :client_applications, :deleted_at

    remove_column :goals, :deleted_at

    remove_column :indicators, :deleted_at

    remove_column :objectives, :deleted_at

    remove_column :payments, :deleted_at

    remove_column :tasks, :deleted_at
    change_column :tasks, :feeling, :string, default: "smile",   null: false

    remove_index :areas, :name => :index_areas_on_deleted_at rescue ActiveRecord::StatementInvalid

    remove_index :hoshins, :name => :index_hoshins_on_deleted_at rescue ActiveRecord::StatementInvalid

    remove_index :companies, :name => :index_companies_on_deleted_at rescue ActiveRecord::StatementInvalid

    remove_index :client_applications, :name => :index_client_applications_on_deleted_at rescue ActiveRecord::StatementInvalid

    remove_index :goals, :name => :index_goals_on_deleted_at rescue ActiveRecord::StatementInvalid

    remove_index :indicators, :name => :index_indicators_on_deleted_at rescue ActiveRecord::StatementInvalid

    remove_index :objectives, :name => :index_objectives_on_deleted_at rescue ActiveRecord::StatementInvalid

    remove_index :payments, :name => :index_payments_on_deleted_at rescue ActiveRecord::StatementInvalid

    remove_index :tasks, :name => :index_tasks_on_deleted_at rescue ActiveRecord::StatementInvalid
  end
end
