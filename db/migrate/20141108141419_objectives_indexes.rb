class ObjectivesIndexes < ActiveRecord::Migration
  def self.up
    remove_index :objectives, :name => :index_objectives_on_parent_id_and_company_id rescue ActiveRecord::StatementInvalid
    add_index :objectives, [:company_id, :parent_id]
  end

  def self.down
    remove_index :objectives, :name => :index_objectives_on_company_id_and_parent_id rescue ActiveRecord::StatementInvalid
    add_index :objectives, [:parent_id, :company_id]
  end
end
