class HoboMigration5 < ActiveRecord::Migration
  def self.up
    add_column :objectives, :hoshin_id, :integer

    add_index :objectives, [:hoshin_id]
  end

  def self.down
    remove_column :objectives, :hoshin_id

    remove_index :objectives, :name => :index_objectives_on_hoshin_id rescue ActiveRecord::StatementInvalid
  end
end
