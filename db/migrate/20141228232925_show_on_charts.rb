class ShowOnCharts < ActiveRecord::Migration
  def self.up
    change_column :users, :preferred_view, :string, :limit => 255, :default => :expanded

    add_column :indicators, :show_on_charts, :boolean, :default => true, :null => false
  end

  def self.down
    change_column :users, :preferred_view, :string, default: "expanded"

    remove_column :indicators, :show_on_charts
  end
end
