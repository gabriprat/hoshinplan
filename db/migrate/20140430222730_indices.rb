class Indices < ActiveRecord::Migration
  def self.up
    add_index :tasks, [:area_id, :status]

    add_index :user_companies, [:user_id, :company_id]
  end

  def self.down
    remove_index :tasks, :name => :index_tasks_on_area_id_and_status rescue ActiveRecord::StatementInvalid

    remove_index :user_companies, :name => :index_user_companies_on_user_id_and_company_id rescue ActiveRecord::StatementInvalid
  end
end
