class Image < ActiveRecord::Migration
  def self.up
    add_column :users, :image, :string
  end

  def self.down
    remove_column :users, :image
  end
end
