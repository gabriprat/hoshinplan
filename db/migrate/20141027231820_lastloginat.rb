class Lastloginat < ActiveRecord::Migration
  def self.up
    add_column :users, :last_login_at, :datetime
    add_column :users, :login_count, :integer
  end

  def self.down
    remove_column :users, :last_login_at
    remove_column :users, :login_count
  end
end
