class AddAncestryToHoshins < ActiveRecord::Migration
  def self.up
    add_column :hoshins, :ancestry, :string
    add_index :hoshins, :ancestry
  end
  def self.down
    remove_index :hoshins, :ancestry
    remove_column :hoshins, :ancestry	
  end
end
