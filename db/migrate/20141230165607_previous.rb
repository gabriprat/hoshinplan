class Previous < ActiveRecord::Migration
  def self.up
    change_column :users, :preferred_view, :string, :limit => 255, :default => :expanded

    add_column :indicator_histories, :previous, :decimal
  end

  def self.down
    change_column :users, :preferred_view, :string, default: "expanded"

    remove_column :indicator_histories, :previous
  end
end
