class DropImageUpload < ActiveRecord::Migration
  def self.up
    rename_column :users, :image_file_name, :image
    remove_column :users, :image_content_type
    remove_column :users, :image_file_size
    remove_column :users, :image_updated_at
  end

  def self.down
    rename_column :users, :image, :image_file_name
    add_column :users, :image_content_type, :string
    add_column :users, :image_file_size, :integer
    add_column :users, :image_updated_at, :datetime
  end
end
