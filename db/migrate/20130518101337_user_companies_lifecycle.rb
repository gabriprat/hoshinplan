class UserCompaniesLifecycle < ActiveRecord::Migration
  def self.up
    add_column :user_companies, :state, :string
    add_column :user_companies, :key_timestamp, :datetime

    add_index :user_companies, [:state]
  end

  def self.down
    remove_column :user_companies, :state
    remove_column :user_companies, :key_timestamp

    remove_index :user_companies, :name => :index_user_companies_on_state rescue ActiveRecord::StatementInvalid
  end
end
