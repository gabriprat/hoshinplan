class SamlCertText < ActiveRecord::Migration
  def self.up
    change_column :auth_providers, :cert, :text, :limit => nil

    change_column :users, :preferred_view, :string, :limit => 255, :default => :expanded
  end

  def self.down
    change_column :auth_providers, :cert, :string

    change_column :users, :preferred_view, :string, default: "expanded"
  end
end
