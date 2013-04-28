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

ActiveRecord::Schema.define(:version => 20130428191952) do

  create_table "areas", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "hoshin_id"
  end

  add_index "areas", ["hoshin_id"], :name => "index_areas_on_hoshin_id"

  create_table "hoshins", :force => true do |t|
    t.string   "name"
    t.integer  "areas_count", :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "indicator_histories", :force => true do |t|
    t.decimal  "value",        :precision => 10, :scale => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "indicator_id"
  end

  add_index "indicator_histories", ["indicator_id"], :name => "index_indicator_histories_on_indicator_id"

  create_table "indicators", :force => true do |t|
    t.string   "name"
    t.decimal  "value",        :precision => 10, :scale => 0
    t.text     "description"
    t.string   "responsible"
    t.boolean  "higher"
    t.string   "frequency"
    t.date     "next_update"
    t.decimal  "goal",         :precision => 10, :scale => 0
    t.decimal  "max_value",    :precision => 10, :scale => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "objective_id"
  end

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
  end

  add_index "objectives", ["area_id"], :name => "index_objectives_on_area_id"

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
  end

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
