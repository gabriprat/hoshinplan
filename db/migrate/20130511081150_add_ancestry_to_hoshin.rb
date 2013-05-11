class AddAncestryToHoshin < ActiveRecord::Migration
  def change
    add_column :hoshins, :ancestry, :string
    add_index :hoshins, :ancestry
  end
end
