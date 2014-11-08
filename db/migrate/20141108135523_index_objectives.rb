class IndexObjectives < ActiveRecord::Migration
  def self.up
    add_index :objectives, [:parent_id, :company_id]
  end

  def self.down
    remove_index :objectives, :name => :index_objectives_on_parent_id_and_company_id rescue ActiveRecord::StatementInvalid
  end
end
