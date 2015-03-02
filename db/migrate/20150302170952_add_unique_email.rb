class AddUniqueEmail < ActiveRecord::Migration
  def self.up
    change_column :users, :preferred_view, :string, :limit => 255, :default => :expanded

    add_index :users, [:email_address], :unique => true
  end

  def self.down
    change_column :users, :preferred_view, :string, default: "expanded"

    remove_index :users, :name => :index_users_on_email_address rescue ActiveRecord::StatementInvalid
  end
end
