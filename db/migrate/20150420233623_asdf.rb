class Asdf < ActiveRecord::Migration
  def self.up
    change_column :users, :preferred_view, :string, :limit => 255, :default => :compact

    remove_column :companies, :plan

    change_column :goals, :name, :string, :limit => 255, :null => false

    change_column :indicators, :name, :string, :limit => 255, :null => false

    change_column :objectives, :name, :string, :limit => 255, :null => false

    change_column :tasks, :name, :string, :limit => 255, :null => false
  end

  def self.down
    change_column :users, :preferred_view, :string, default: "expanded"

    add_column :companies, :plan, :string, limit: 244

    change_column :goals, :name, :string

    change_column :indicators, :name, :string

    change_column :objectives, :name, :string

    change_column :tasks, :name, :string
  end
end
