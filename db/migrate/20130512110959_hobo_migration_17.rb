class HoboMigration17 < ActiveRecord::Migration
  def self.up
    add_column :objectives, :parent_id, :integer

    add_index :objectives, [:parent_id]
  end

  def self.down
    remove_column :objectives, :parent_id

    remove_index :objectives, :name => :index_objectives_on_parent_id rescue ActiveRecord::StatementInvalid
  end
end
