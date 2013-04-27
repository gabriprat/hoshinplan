class HoboMigration5 < ActiveRecord::Migration
  def self.up
    add_column :tasks, :key_timestamp, :datetime
    change_column :tasks, :status, :string, :default => nil, :limit => 255, :null => true

    add_index :tasks, [:status]
  end

  def self.down
    remove_column :tasks, :key_timestamp
    change_column :tasks, :status, :string, :default => "active", :null => false

    remove_index :tasks, :name => :index_tasks_on_status rescue ActiveRecord::StatementInvalid
  end
end
