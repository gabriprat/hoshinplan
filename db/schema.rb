# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130511084613) do

  create_table "areas", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "hoshin_id"
    t.integer  "position"
  end

  add_index "areas", ["hoshin_id"], :name => "index_areas_on_hoshin_id"

  create_table "authorizations", :force => true do |t|
    t.string   "provider",      :null => false
    t.string   "uid",           :null => false
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

  add_index "authorizations", ["email_address"], :name => "index_authorizations_on_email_address"
  add_index "authorizations", ["provider"], :name => "index_authorizations_on_provider"
  add_index "authorizations", ["uid"], :name => "index_authorizations_on_uid"
  add_index "authorizations", ["user_id"], :name => "index_authorizations_on_user_id"

  create_table "companies", :force => true do |t|
    t.string   "name"
    t.integer  "hoshins_count", :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "hoshins", :force => true do |t|
    t.string   "name"
    t.integer  "areas_count", :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id"
    t.integer  "parent_id"
  end

  add_index "hoshins", ["company_id"], :name => "index_hoshins_on_company_id"
  add_index "hoshins", ["parent_id"], :name => "index_hoshins_on_parent_id"

  create_table "indicator_histories", :force => true do |t|
    t.decimal  "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "indicator_id"
  end

  add_index "indicator_histories", ["indicator_id"], :name => "index_indicator_histories_on_indicator_id"

  create_table "indicators", :force => true do |t|
    t.string   "name"
    t.decimal  "value"
    t.text     "description"
    t.string   "responsible"
    t.boolean  "higher"
    t.string   "frequency"
    t.date     "next_update"
    t.decimal  "goal"
    t.decimal  "max_value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "objective_id"
    t.integer  "area_id"
    t.integer  "position"
  end

  add_index "indicators", ["area_id"], :name => "index_indicators_on_area_id"
  add_index "indicators", ["objective_id"], :name => "index_indicators_on_objective_id"

  create_table "objectives", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "responsible"
    t.integer  "indicators_count", :default => 0, :null => false
    t.integer  "tasks_count",      :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "area_id"
    t.integer  "hoshin_id"
    t.integer  "position"
  end

  add_index "objectives", ["area_id"], :name => "index_objectives_on_area_id"
  add_index "objectives", ["hoshin_id"], :name => "index_objectives_on_hoshin_id"

  create_table "tasks", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "responsible"
    t.date     "deadline"
    t.date     "original_deadline"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "objective_id"
    t.string   "status",            :default => "active"
    t.datetime "key_timestamp"
    t.integer  "position"
    t.integer  "area_id"
  end

  add_index "tasks", ["area_id"], :name => "index_tasks_on_area_id"
  add_index "tasks", ["objective_id"], :name => "index_tasks_on_objective_id"
  add_index "tasks", ["status"], :name => "index_tasks_on_status"

  create_table "users", :force => true do |t|
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "name"
    t.string   "email_address"
    t.boolean  "administrator",                           :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state",                                   :default => "inactive"
    t.datetime "key_timestamp"
  end

  add_index "users", ["state"], :name => "index_users_on_state"

end
