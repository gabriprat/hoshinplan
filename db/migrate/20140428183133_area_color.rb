class AreaColor < ActiveRecord::Migration
  def self.up
    add_column :areas, :color, :string, :null => false, :default => "#FFFFFF"
    change_column :areas, :name, :string, :limit => 255, :null => false

    add_index :tasks, [:deadline, :status]
  end

  def self.down
    remove_column :areas, :color
    change_column :areas, :name, :string

    remove_index :tasks, :name => :index_tasks_on_deadline_and_status rescue ActiveRecord::StatementInvalid
  end
end
