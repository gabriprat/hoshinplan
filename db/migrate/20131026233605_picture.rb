class Picture < ActiveRecord::Migration
  def self.up
    rename_column :users, :image, :picture
  end

  def self.down
    rename_column :users, :picture, :image
  end
end
