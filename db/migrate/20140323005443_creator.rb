class Creator < ActiveRecord::Migration
  def self.up
    add_column :areas, :creator_id, :integer

    add_column :hoshins, :creator_id, :integer

    add_column :companies, :creator_id, :integer

    add_column :goals, :creator_id, :integer

    add_column :indicator_histories, :creator_id, :integer

    add_column :indicators, :creator_id, :integer

    add_column :objectives, :creator_id, :integer

    add_column :tasks, :creator_id, :integer

    add_index :areas, [:creator_id]

    add_index :hoshins, [:creator_id]

    add_index :companies, [:creator_id]

    add_index :goals, [:creator_id]

    add_index :indicator_histories, [:creator_id]

    add_index :indicators, [:creator_id]

    add_index :objectives, [:creator_id]

    add_index :tasks, [:creator_id]
  end

  def self.down
    remove_column :areas, :creator_id

    remove_column :hoshins, :creator_id

    remove_column :companies, :creator_id

    remove_column :goals, :creator_id

    remove_column :indicator_histories, :creator_id

    remove_column :indicators, :creator_id

    remove_column :objectives, :creator_id

    remove_column :tasks, :creator_id

    remove_index :areas, :name => :index_areas_on_creator_id rescue ActiveRecord::StatementInvalid

    remove_index :hoshins, :name => :index_hoshins_on_creator_id rescue ActiveRecord::StatementInvalid

    remove_index :companies, :name => :index_companies_on_creator_id rescue ActiveRecord::StatementInvalid

    remove_index :goals, :name => :index_goals_on_creator_id rescue ActiveRecord::StatementInvalid

    remove_index :indicator_histories, :name => :index_indicator_histories_on_creator_id rescue ActiveRecord::StatementInvalid

    remove_index :indicators, :name => :index_indicators_on_creator_id rescue ActiveRecord::StatementInvalid

    remove_index :objectives, :name => :index_objectives_on_creator_id rescue ActiveRecord::StatementInvalid

    remove_index :tasks, :name => :index_tasks_on_creator_id rescue ActiveRecord::StatementInvalid
  end
end
