class IndexUserCompanies < ActiveRecord::Migration
  def self.up
    add_index :user_companies, [:user_id, :state]
  end

  def self.down
    remove_index :user_companies, :name => :index_user_companies_on_user_id_and_state rescue ActiveRecord::StatementInvalid
  end
end
