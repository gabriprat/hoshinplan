class BlindNegletedObjectives < ActiveRecord::Migration
  def self.up
    change_column :users, :preferred_view, :string, :limit => 255, :default => :compact

    add_column :objectives, :negleted, :boolean, :default => false, :required => true
    add_column :objectives, :blind, :boolean, :default => true, :required => true
  end

  def self.down
    change_column :users, :preferred_view, :string, default: "compact"

    remove_column :objectives, :negleted
    remove_column :objectives, :blind
  end
end
