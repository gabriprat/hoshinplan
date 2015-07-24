class AddLog < ActiveRecord::Migration
  def self.up
    create_table :logs do |t|
      t.string   :title
      t.text     :body
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :company_id, :null => false
      t.integer  :creator_id
      t.integer  :hoshin_id, :null => false
      t.integer  :area_id, :null => false
      t.integer  :goal_id, :null => false
      t.integer  :objective_id, :null => false
      t.integer  :indicator_id, :null => false
      t.string   :type
      t.integer  :task_id, :null => false
    end
    add_index :logs, [:company_id]
    add_index :logs, [:creator_id]
    add_index :logs, [:type]
    add_index :logs, [:hoshin_id]
    add_index :logs, [:area_id]
    add_index :logs, [:goal_id]
    add_index :logs, [:objective_id]
    add_index :logs, [:indicator_id]
    add_index :logs, [:task_id]

    change_column :users, :preferred_view, :string, :limit => 255, :default => :expanded

    change_column :tasks, :feeling, :string, :limit => 255, :null => false, :default => :smile
  end

  def self.down
    change_column :users, :preferred_view, :string, default: "expanded"

    change_column :tasks, :feeling, :string, default: "smile",   null: false

    drop_table :logs
  end
end
