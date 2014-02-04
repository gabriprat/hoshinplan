class DropUserCompaniesAdministrator < ActiveRecord::Migration
  def self.up
    remove_column :user_companies, :administrator
  end

  def self.down
    add_column :user_companies, :administrator, :boolean, :default => false
  end
end
