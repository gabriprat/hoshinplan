class HistoryCompany < ActiveRecord::Migration
  def self.up
    add_column :indicator_histories, :company_id, :integer

    add_index :indicator_histories, [:company_id]
  end

  def self.down
    remove_column :indicator_histories, :company_id

    remove_index :indicator_histories, :name => :index_indicator_histories_on_company_id rescue ActiveRecord::StatementInvalid
  end
end
