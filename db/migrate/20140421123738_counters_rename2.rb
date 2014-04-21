class CountersRename2 < ActiveRecord::Migration
  def self.up
    rename_column :areas, :kpis_count, :indicators_count
  end

  def self.down
    rename_column :areas, :indicators_count, :kpis_count
  end
end
