class BelongsToCompany < ActiveRecord::Migration
  def self.up
    add_column :areas, :company_id, :integer

    add_column :indicators, :company_id, :integer

    add_column :objectives, :company_id, :integer

    change_column :users, :state, :string, :limit => 255, :default => "inactive"

    add_column :tasks, :company_id, :integer

    add_index :areas, [:company_id]

    add_index :indicators, [:company_id]

    add_index :objectives, [:company_id]

    add_index :tasks, [:company_id]
  end

  def self.down
    remove_column :areas, :company_id

    remove_column :indicators, :company_id

    remove_column :objectives, :company_id

    change_column :users, :state, :string, :default => "active"

    remove_column :tasks, :company_id

    remove_index :areas, :name => :index_areas_on_company_id rescue ActiveRecord::StatementInvalid

    remove_index :indicators, :name => :index_indicators_on_company_id rescue ActiveRecord::StatementInvalid

    remove_index :objectives, :name => :index_objectives_on_company_id rescue ActiveRecord::StatementInvalid

    remove_index :tasks, :name => :index_tasks_on_company_id rescue ActiveRecord::StatementInvalid
  end
end
