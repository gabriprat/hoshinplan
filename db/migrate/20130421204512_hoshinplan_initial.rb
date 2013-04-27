class HoshinplanInitial < ActiveRecord::Migration
  def self.up
    create_table :tasks do |t|
      t.string   :name
      t.text     :description
      t.string   :responsible
      t.date     :deadline
      t.date     :original_deadline
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :area_id
    end
    add_index :tasks, [:area_id]

    create_table :areas do |t|
      t.string   :name
      t.text     :description
      t.integer  :objectives_count, :default => 0, :null => false
      t.integer  :indicators_count, :default => 0, :null => false
      t.integer  :tasks_count, :default => 0, :null => false
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :hoshin_id
    end
    add_index :areas, [:hoshin_id]

    create_table :hoshins do |t|
      t.string   :name
      t.integer  :areas_count, :default => 0, :null => false
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :objectives do |t|
      t.string   :name
      t.text     :description
      t.string   :responsible
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :area_id
    end
    add_index :objectives, [:area_id]

    create_table :indicator_histories do |t|
      t.decimal  :value
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :indicator_id
    end
    add_index :indicator_histories, [:indicator_id]

    create_table :indicators do |t|
      t.string  :name
      t.decimal :value
      t.text    :description
      t.string  :responsible
      t.boolean :higher
      t.string  :frequency
      t.integer :area_id
    end
    add_index :indicators, [:area_id]
  end

  def self.down
    drop_table :tasks
    drop_table :areas
    drop_table :hoshins
    drop_table :objectives
    drop_table :indicator_histories
    drop_table :indicators
  end
end
