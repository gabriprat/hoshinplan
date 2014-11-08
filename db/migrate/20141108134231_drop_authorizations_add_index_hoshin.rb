class DropAuthorizationsAddIndexHoshin < ActiveRecord::Migration
  def self.up
    drop_table :authorizations

    add_index :hoshins, [:company_id, :parent_id]
  end

  def self.down
    create_table "authorizations", force: true do |t|
      t.string   "provider",      null: false
      t.string   "uid",           null: false
      t.string   "email_address"
      t.string   "name"
      t.string   "nickname"
      t.string   "location"
      t.string   "image"
      t.text     "description"
      t.string   "phone"
      t.text     "urls"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "user_id"
    end

    add_index "authorizations", ["email_address"], name: "index_authorizations_on_email_address", using: :btree
    add_index "authorizations", ["provider"], name: "index_authorizations_on_provider", using: :btree
    add_index "authorizations", ["uid"], name: "index_authorizations_on_uid", using: :btree
    add_index "authorizations", ["user_id"], name: "index_authorizations_on_user_id", using: :btree

    remove_index :hoshins, :name => :index_hoshins_on_company_id_and_parent_id rescue ActiveRecord::StatementInvalid
  end
end
