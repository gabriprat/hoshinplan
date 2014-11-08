class RemoveObjectivesIndexes < ActiveRecord::Migration
  def self.up
    remove_index :objectives, :name => :index_objectives_on_company_id_and_parent_id rescue ActiveRecord::StatementInvalid
  end

  def self.down
    add_index :objectives, [:company_id, :parent_id]
  end
end
