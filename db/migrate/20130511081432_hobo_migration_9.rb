class HoboMigration9 < ActiveRecord::Migration
  def self.up
    create_table :companies do |t|
      t.string   :name
      t.integer  :hoshins_count, :default => 0, :null => false
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_column :hoshins, :company_id, :integer

    remove_index :hoshins, :name => :index_hoshins_on_ancestry rescue ActiveRecord::StatementInvalid
    add_index :hoshins, [:company_id]
  end

  def self.down
    remove_column :hoshins, :company_id

    drop_table :companies

    remove_index :hoshins, :name => :index_hoshins_on_company_id rescue ActiveRecord::StatementInvalid
    add_index :hoshins, [:ancestry]
  end
end
