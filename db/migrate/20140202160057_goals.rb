class Goals < ActiveRecord::Migration
  def self.up
    create_table :goals do |t|
      t.string   :name
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :hoshin_id
      t.integer  :company_id
      t.integer  :position
    end
    add_index :goals, [:hoshin_id]
    add_index :goals, [:company_id]
  end

  def self.down
    drop_table :goals
  end
end
