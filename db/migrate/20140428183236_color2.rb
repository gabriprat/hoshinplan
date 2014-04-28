class Color2 < ActiveRecord::Migration
  def self.up
    change_column :areas, :color, :string, :limit => 255, :null => true, :default => nil
  end

  def self.down
    change_column :areas, :color, :string, :default => "#FFFFFF", :null => false
  end
end
