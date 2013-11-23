class HoshinHeader < ActiveRecord::Migration
  def self.up
    add_column :hoshins, :header, :text
  end

  def self.down
    remove_column :hoshins, :header
  end
end
