class UserCompanies2 < ActiveRecord::Migration
  def self.up
    add_column :user_companies, :user_id, :integer
    add_column :user_companies, :company_id, :integer

    add_index :user_companies, [:user_id]
    add_index :user_companies, [:company_id]
  end

  def self.down
    remove_column :user_companies, :user_id
    remove_column :user_companies, :company_id

    remove_index :user_companies, :name => :index_user_companies_on_user_id rescue ActiveRecord::StatementInvalid
    remove_index :user_companies, :name => :index_user_companies_on_company_id rescue ActiveRecord::StatementInvalid
  end
end
