class FirstNameLastName < ActiveRecord::Migration
  def self.up
    add_column :users, :firstName, :string
    add_column :users, :lastName, :string
    change_column :users, :preferred_view, :string, :limit => 255, :default => :compact
  end

  def self.down
    remove_column :users, :firstName
    remove_column :users, :lastName
    change_column :users, :preferred_view, :string, default: "compact"
  end
end
