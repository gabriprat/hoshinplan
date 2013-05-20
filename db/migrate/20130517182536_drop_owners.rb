class DropOwners < ActiveRecord::Migration
  def self.up
    remove_column :companies, :owner_id

    add_column :user_companies, :administrator, :boolean, :default => false

    remove_index :companies, :name => :index_companies_on_owner_id rescue ActiveRecord::StatementInvalid
  end

  def self.down
    add_column :companies, :owner_id, :integer

    remove_column :user_companies, :administrator

    add_index :companies, [:owner_id]
  end
end
