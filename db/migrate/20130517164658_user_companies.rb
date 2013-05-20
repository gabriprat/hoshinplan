class UserCompanies < ActiveRecord::Migration
  def self.up
    create_table :user_companies do |t|
      t.datetime :created_at
      t.datetime :updated_at
    end
  end

  def self.down
    drop_table :user_companies
  end
end
