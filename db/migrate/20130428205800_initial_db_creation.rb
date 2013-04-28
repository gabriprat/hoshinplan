class InitialDbCreate < ActiveRecord::Migration
  def self.up
    create_table :objectives do |t|
      t.string   :name
      t.text     :description
      t.string   :responsible
      t.integer  :indicators_count, :default => 0, :null => false
      t.integer  :tasks_count, :default => 0, :null => false
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :area_id
    end
    add_index :objectives, [:area_id]

    create_table :users do |t|
      t.string   :crypted_password, :limit => 40
      t.string   :salt, :limit => 40
      t.string   :remember_token
      t.datetime :remember_token_expires_at
      t.string   :name
      t.string   :email_address
      t.boolean  :administrator, :default => false
      t.datetime :created_at
      t.datetime :updated_at
      t.string   :state, :default => "inactive"
      t.datetime :key_timestamp
    end
    add_index :users, [:state]

    create_table :tasks do |t|
      t.string   :name
      t.text     :description
      t.string   :responsible
      t.date     :deadline
      t.date     :original_deadline
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :objective_id
      t.string   :status, :default => "active"
      t.datetime :key_timestamp
    end
    add_index :tasks, [:objective_id]
    add_index :tasks, [:status]

    create_table :indicators do |t|
      t.string   :name
      t.decimal  :value
      t.text     :description
      t.string   :responsible
      t.boolean  :higher
      t.string   :frequency
      t.date     :next_update
      t.decimal  :goal
      t.decimal  :max_value
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :objective_id
    end
    add_index :indicators, [:objective_id]

    create_table :hoshins do |t|
      t.string   :name
      t.integer  :areas_count, :default => 0, :null => false
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :indicator_histories do |t|
      t.decimal  :value
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :indicator_id
    end
    add_index :indicator_histories, [:indicator_id]

    create_table :areas do |t|
      t.string   :name
      t.text     :description
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :hoshin_id
    end
    add_index :areas, [:hoshin_id]
  end

  def self.down
    drop_table :objectives
    drop_table :users
    drop_table :tasks
    drop_table :indicators
    drop_table :hoshins
    drop_table :indicator_histories
    drop_table :areas
  end
end
