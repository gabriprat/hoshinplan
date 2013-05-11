class HoboMigration10 < ActiveRecord::Migration
  def self.up
    add_column :hoshins, :parent_id, :integer

    add_index :hoshins, [:parent_id]
  end

  def self.down
    remove_column :hoshins, :parent_id

    remove_index :hoshins, :name => :index_hoshins_on_parent_id rescue ActiveRecord::StatementInvalid
  end
end
