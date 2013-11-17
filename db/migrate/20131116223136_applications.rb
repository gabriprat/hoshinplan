class Applications < ActiveRecord::Migration
  def self.up
    create_table :applications do |t|
      t.string   :name
      t.string   :description
      t.string   :key
      t.string   :secret
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :user_id
    end
    add_index :applications, [:user_id]
  end

  def self.down
    drop_table :applications
  end
end
