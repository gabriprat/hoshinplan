class CompanyEmaiDomains < ActiveRecord::Migration
  def self.up
    create_table :company_email_domains do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.string   :domain
      t.integer  :company_id
    end
    add_index :company_email_domains, [:domain, :company_id]
    add_index :company_email_domains, [:company_id]

    change_column :users, :preferred_view, :string, :limit => 255, :default => :expanded

    change_column :tasks, :feeling, :string, :limit => 255, :null => false, :default => :smile
  end

  def self.down
    change_column :users, :preferred_view, :string, default: "expanded"

    change_column :tasks, :feeling, :string, default: "smile",   null: false

    drop_table :company_email_domains
  end
end
