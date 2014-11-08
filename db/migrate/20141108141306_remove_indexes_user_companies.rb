class RemoveIndexesUserCompanies < ActiveRecord::Migration
  def self.up
    remove_index :user_companies, :name => :index_user_companies_on_company_id_and_user_id rescue ActiveRecord::StatementInvalid
    remove_index :user_companies, :name => :index_user_companies_on_user_id_and_state rescue ActiveRecord::StatementInvalid
  end

  def self.down
    add_index :user_companies, [:company_id, :user_id]
    add_index :user_companies, [:user_id, :state]
  end
end
