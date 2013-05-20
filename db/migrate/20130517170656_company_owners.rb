class CompanyOwners < ActiveRecord::Migration
  def self.up
    add_column :companies, :owner_id, :integer

    add_index :companies, [:owner_id]
  end

  def self.down
    remove_column :companies, :owner_id

    remove_index :companies, :name => :index_companies_on_owner_id rescue ActiveRecord::StatementInvalid
  end
end
