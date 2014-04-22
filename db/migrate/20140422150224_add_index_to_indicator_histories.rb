class AddIndexToIndicatorHistories < ActiveRecord::Migration
  def change
    add_index :indicator_histories, [:indicator_id, :day]
  end
end
