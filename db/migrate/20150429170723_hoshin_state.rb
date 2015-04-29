class HoshinState < ActiveRecord::Migration
  def self.up
    change_column :users, :preferred_view, :string, :limit => 255, :default => :compact

    add_column :hoshins, :state, :string, :default => "active"
    add_column :hoshins, :key_timestamp, :datetime

    add_index :hoshins, [:state]
  end

  def self.down
    change_column :users, :preferred_view, :string, default: "compact"

    remove_column :hoshins, :state
    remove_column :hoshins, :key_timestamp

    remove_index :hoshins, :name => :index_hoshins_on_state rescue ActiveRecord::StatementInvalid
  end
end
