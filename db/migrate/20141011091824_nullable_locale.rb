class NullableLocale < ActiveRecord::Migration
  def self.up
    change_column :users, :language, :string, :limit => 255, :default => nil
  end

  def self.down
    change_column :users, :language, :string, :default => "es"
  end
end
