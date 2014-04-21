class CountersRename < ActiveRecord::Migration
  def self.up
    rename_column :hoshins, :kpis_count, :indicators_count
  end

  def self.down
    rename_column :hoshins, :indicators_count, :kpis_count
  end
end
