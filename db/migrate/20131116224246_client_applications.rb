class ClientApplications < ActiveRecord::Migration
  def self.up
    rename_table :applications, :client_applications

    remove_index :client_applications, :name => :index_applications_on_user_id rescue ActiveRecord::StatementInvalid
    add_index :client_applications, [:user_id]
  end

  def self.down
    rename_table :client_applications, :applications

    remove_index :applications, :name => :index_client_applications_on_user_id rescue ActiveRecord::StatementInvalid
    add_index :applications, [:user_id]
  end
end
