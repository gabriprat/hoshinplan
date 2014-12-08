class UniqueIndicatorHistoriesDayIndicatorId < ActiveRecord::Migration
  def self.up
    remove_index :indicator_histories, :name => :index_indicator_histories_on_indicator_id_and_day rescue ActiveRecord::StatementInvalid
    add_index :indicator_histories, [:indicator_id, :day], :unique => true
  end

  def self.down
    remove_index :indicator_histories, :name => :index_indicator_histories_on_indicator_id_and_day rescue ActiveRecord::StatementInvalid
    add_index :indicator_histories, [:indicator_id, :day]
  end
end
