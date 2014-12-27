class NotNullRelationships < ActiveRecord::Migration
  def self.up
    change_column :areas, :hoshin_id, :integer, :null => false
    change_column :areas, :company_id, :integer, :null => false

    change_column :users, :preferred_view, :string, :limit => 255, :default => :expanded

    change_column :goals, :hoshin_id, :integer, :null => false
    change_column :goals, :company_id, :integer, :null => false

    change_column :indicator_histories, :indicator_id, :integer, :null => false
    change_column :indicator_histories, :company_id, :integer, :null => false

    change_column :indicators, :area_id, :integer, :null => false
    change_column :indicators, :company_id, :integer, :null => false
    change_column :indicators, :hoshin_id, :integer, :null => false

    change_column :objectives, :area_id, :integer, :null => false
    change_column :objectives, :hoshin_id, :integer, :null => false
    change_column :objectives, :company_id, :integer, :null => false

    change_column :tasks, :area_id, :integer, :null => false
    change_column :tasks, :company_id, :integer, :null => false
    change_column :tasks, :hoshin_id, :integer, :null => false
  end

  def self.down
    change_column :areas, :hoshin_id, :integer
    change_column :areas, :company_id, :integer

    change_column :users, :preferred_view, :string, default: "expanded"

    change_column :goals, :hoshin_id, :integer
    change_column :goals, :company_id, :integer

    change_column :indicator_histories, :indicator_id, :integer
    change_column :indicator_histories, :company_id, :integer

    change_column :indicators, :area_id, :integer
    change_column :indicators, :company_id, :integer
    change_column :indicators, :hoshin_id, :integer

    change_column :objectives, :area_id, :integer
    change_column :objectives, :hoshin_id, :integer
    change_column :objectives, :company_id, :integer

    change_column :tasks, :area_id, :integer
    change_column :tasks, :company_id, :integer
    change_column :tasks, :hoshin_id, :integer
  end
end
