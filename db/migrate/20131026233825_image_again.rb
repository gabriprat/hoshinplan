class ImageAgain < ActiveRecord::Migration
  def self.up
    rename_column :users, :picture, :image
  end

  def self.down
    rename_column :users, :image, :picture
  end
end
