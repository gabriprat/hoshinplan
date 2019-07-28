# encoding: UTF-8
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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20190728103703) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "a", id: false, force: :cascade do |t|
    t.integer "id"
    t.date    "trial_ends_at"
  end

  create_table "areas", force: :cascade do |t|
    t.string   "name",        null: false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "hoshin_id",   null: false
    t.integer  "position"
    t.integer  "company_id",  null: false
    t.integer  "creator_id"
    t.string   "color"
    t.datetime "deleted_at"
  end

  add_index "areas", ["company_id"], name: "index_areas_on_company_id", using: :btree
  add_index "areas", ["creator_id"], name: "index_areas_on_creator_id", using: :btree
  add_index "areas", ["deleted_at"], name: "index_areas_on_deleted_at", using: :btree
  add_index "areas", ["hoshin_id"], name: "index_areas_on_hoshin_id", using: :btree

  create_table "auth_providers", force: :cascade do |t|
    t.string   "email_domain", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.string   "openid_url"
    t.string   "issuer"
    t.string   "sso_url"
    t.text     "cert"
    t.string   "fingerprint"
    t.string   "id_format"
    t.integer  "company_id"
  end

  add_index "auth_providers", ["company_id"], name: "index_auth_providers_on_company_id", using: :btree
  add_index "auth_providers", ["email_domain", "type"], name: "index_auth_providers_on_email_domain_and_type", unique: true, using: :btree
  add_index "auth_providers", ["type"], name: "index_auth_providers_on_type", using: :btree

  create_table "authorizations", force: :cascade do |t|
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

  create_table "billing_details", force: :cascade do |t|
    t.string   "company_name"
    t.string   "address_line_1"
    t.string   "contact_name"
    t.string   "contact_email"
    t.string   "vat_number"
    t.string   "country"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "address_line_2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "stripe_client_id"
    t.string   "card_brand"
    t.string   "card_last4"
    t.integer  "card_exp_month"
    t.integer  "card_exp_year"
    t.string   "card_stripe_token"
    t.integer  "creator_id"
    t.integer  "company_id"
    t.datetime "deleted_at"
    t.boolean  "vies_valid",          default: false
    t.string   "sage_one_contact_id"
    t.string   "card_name"
    t.string   "send_invoice_cc"
  end

  add_index "billing_details", ["company_id"], name: "index_billing_details_on_company_id", unique: true, using: :btree
  add_index "billing_details", ["creator_id"], name: "index_billing_details_on_creator_id", using: :btree

  create_table "billing_plans", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.text     "features"
    t.string   "frequency"
    t.integer  "interval"
    t.string   "amount_currency"
    t.decimal  "amount_value",    precision: 8, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "id_paypal"
    t.string   "status_paypal"
    t.string   "brief"
    t.string   "css_class"
    t.integer  "position"
    t.integer  "users"
    t.integer  "workers"
    t.string   "stripe_id"
    t.decimal  "monthly_value",   precision: 8, scale: 2
    t.integer  "min_users",                               default: 5, null: false
  end

  create_table "client_applications", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.string   "key"
    t.string   "secret"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.datetime "deleted_at"
  end

  add_index "client_applications", ["deleted_at"], name: "index_client_applications_on_deleted_at", using: :btree
  add_index "client_applications", ["user_id"], name: "index_client_applications_on_user_id", using: :btree

  create_table "clockwork_events", force: :cascade do |t|
    t.string   "name"
    t.string   "job"
    t.integer  "frequency_quantity"
    t.string   "frequency_period"
    t.string   "at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "options"
  end

  create_table "companies", force: :cascade do |t|
    t.string   "name"
    t.integer  "hoshins_count",                                      default: 0,     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.boolean  "unlimited",                                          default: false, null: false
    t.datetime "deleted_at"
    t.integer  "subscriptions_count",                                default: 0,     null: false
    t.decimal  "credit",                     precision: 8, scale: 2, default: 0.0
    t.date     "trial_ends_at"
    t.boolean  "payment_error"
    t.integer  "minimum_subscription_users"
    t.jsonb    "charts_config"
    t.integer  "partner_id"
  end

  add_index "companies", ["creator_id"], name: "index_companies_on_creator_id", using: :btree
  add_index "companies", ["deleted_at"], name: "index_companies_on_deleted_at", using: :btree
  add_index "companies", ["partner_id"], name: "index_companies_on_partner_id", using: :btree

  create_table "company_email_domains", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "domain"
    t.integer  "company_id", null: false
  end

  add_index "company_email_domains", ["company_id"], name: "index_company_email_domains_on_company_id", using: :btree
  add_index "company_email_domains", ["domain", "company_id"], name: "index_company_email_domains_on_domain_and_company_id", using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",               default: 0, null: false
    t.integer  "attempts",               default: 0, null: false
    t.text     "handler",                            null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "flipper_features", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "flipper_features", ["name"], name: "index_flipper_features_on_name", unique: true, using: :btree

  create_table "flipper_gates", force: :cascade do |t|
    t.integer  "flipper_feature_id", null: false
    t.string   "name",               null: false
    t.string   "value"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "flipper_gates", ["flipper_feature_id", "name", "value"], name: "index_flipper_gates_on_flipper_feature_id_and_name_and_value", unique: true, using: :btree

  create_table "gdpr_en", id: false, force: :cascade do |t|
    t.string "email_address"
    t.string "firstName"
  end

  create_table "gdpr_es", id: false, force: :cascade do |t|
    t.string "email_address"
    t.string "firstName"
  end

  create_table "generic_comments", force: :cascade do |t|
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id",   null: false
    t.integer  "creator_id"
    t.integer  "hoshin_id"
    t.integer  "area_id"
    t.integer  "goal_id"
    t.integer  "objective_id"
    t.integer  "indicator_id"
    t.string   "type"
    t.integer  "task_id"
  end

  add_index "generic_comments", ["area_id", "created_at"], name: "index_generic_comments_on_area_id_and_created_at", using: :btree
  add_index "generic_comments", ["area_id"], name: "index_generic_comments_on_area_id", using: :btree
  add_index "generic_comments", ["company_id", "created_at"], name: "index_generic_comments_on_company_id_and_created_at", using: :btree
  add_index "generic_comments", ["company_id"], name: "index_generic_comments_on_company_id", using: :btree
  add_index "generic_comments", ["creator_id"], name: "index_generic_comments_on_creator_id", using: :btree
  add_index "generic_comments", ["goal_id", "created_at"], name: "index_generic_comments_on_goal_id_and_created_at", using: :btree
  add_index "generic_comments", ["goal_id"], name: "index_generic_comments_on_goal_id", using: :btree
  add_index "generic_comments", ["hoshin_id", "created_at"], name: "index_generic_comments_on_hoshin_id_and_created_at", using: :btree
  add_index "generic_comments", ["hoshin_id"], name: "index_generic_comments_on_hoshin_id", using: :btree
  add_index "generic_comments", ["indicator_id", "created_at"], name: "index_generic_comments_on_indicator_id_and_created_at", using: :btree
  add_index "generic_comments", ["indicator_id"], name: "index_generic_comments_on_indicator_id", using: :btree
  add_index "generic_comments", ["objective_id", "created_at"], name: "index_generic_comments_on_objective_id_and_created_at", using: :btree
  add_index "generic_comments", ["objective_id"], name: "index_generic_comments_on_objective_id", using: :btree
  add_index "generic_comments", ["task_id", "created_at"], name: "index_generic_comments_on_task_id_and_created_at", using: :btree
  add_index "generic_comments", ["task_id"], name: "index_generic_comments_on_task_id", using: :btree
  add_index "generic_comments", ["type"], name: "index_generic_comments_on_type", using: :btree

  create_table "goals", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "hoshin_id",  null: false
    t.integer  "company_id", null: false
    t.integer  "position"
    t.integer  "creator_id"
    t.datetime "deleted_at"
  end

  add_index "goals", ["company_id"], name: "index_goals_on_company_id", using: :btree
  add_index "goals", ["creator_id"], name: "index_goals_on_creator_id", using: :btree
  add_index "goals", ["deleted_at"], name: "index_goals_on_deleted_at", using: :btree
  add_index "goals", ["hoshin_id"], name: "index_goals_on_hoshin_id", using: :btree

  create_table "health_histories", force: :cascade do |t|
    t.date     "day"
    t.decimal  "objectives_health"
    t.decimal  "indicators_health"
    t.decimal  "tasks_health"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "hoshin_id",         null: false
    t.integer  "company_id",        null: false
  end

  add_index "health_histories", ["company_id"], name: "index_health_histories_on_company_id", using: :btree
  add_index "health_histories", ["hoshin_id", "day"], name: "index_health_histories_on_hoshin_id_and_day", unique: true, using: :btree
  add_index "health_histories", ["hoshin_id"], name: "index_health_histories_on_hoshin_id", using: :btree

  create_table "hoshins", force: :cascade do |t|
    t.string   "name",                       default: "plan",   null: false
    t.integer  "areas_count",                default: 0,        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id"
    t.text     "header"
    t.integer  "creator_id"
    t.integer  "objectives_count",           default: 0,        null: false
    t.integer  "goals_count",                default: 0,        null: false
    t.integer  "indicators_count",           default: 0,        null: false
    t.integer  "tasks_count",                default: 0,        null: false
    t.integer  "outdated_indicators_count",  default: 0,        null: false
    t.integer  "outdated_tasks_count",       default: 0,        null: false
    t.integer  "blind_objectives_count",     default: 0,        null: false
    t.integer  "neglected_objectives_count", default: 0,        null: false
    t.integer  "hoshins_count",              default: 0,        null: false
    t.datetime "health_updated_at"
    t.string   "state",                      default: "active"
    t.datetime "key_timestamp"
    t.datetime "deleted_at"
    t.string   "color"
    t.string   "ancestry"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "tasks_visible_days",         default: 110,      null: false
    t.integer  "position"
  end

  add_index "hoshins", ["company_id"], name: "index_hoshins_on_company_id", using: :btree
  add_index "hoshins", ["creator_id"], name: "index_hoshins_on_creator_id", using: :btree
  add_index "hoshins", ["deleted_at"], name: "index_hoshins_on_deleted_at", using: :btree
  add_index "hoshins", ["state"], name: "index_hoshins_on_state", using: :btree

  create_table "indicator_events", force: :cascade do |t|
    t.date     "day",          null: false
    t.string   "name",         null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.integer  "company_id",   null: false
    t.integer  "indicator_id", null: false
  end

  add_index "indicator_events", ["company_id"], name: "index_indicator_events_on_company_id", using: :btree
  add_index "indicator_events", ["creator_id"], name: "index_indicator_events_on_creator_id", using: :btree
  add_index "indicator_events", ["indicator_id", "day"], name: "index_indicator_events_on_indicator_id_and_day", using: :btree
  add_index "indicator_events", ["indicator_id"], name: "index_indicator_events_on_indicator_id", using: :btree

  create_table "indicator_histories", force: :cascade do |t|
    t.decimal  "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "indicator_id",   null: false
    t.date     "day"
    t.decimal  "goal"
    t.integer  "creator_id"
    t.integer  "company_id",     null: false
    t.integer  "responsible_id"
    t.decimal  "previous"
    t.string   "comment"
  end

  add_index "indicator_histories", ["company_id"], name: "index_indicator_histories_on_company_id", using: :btree
  add_index "indicator_histories", ["creator_id"], name: "index_indicator_histories_on_creator_id", using: :btree
  add_index "indicator_histories", ["indicator_id", "day"], name: "index_indicator_histories_on_indicator_id_and_day", unique: true, using: :btree
  add_index "indicator_histories", ["indicator_id"], name: "index_indicator_histories_on_indicator_id", using: :btree
  add_index "indicator_histories", ["responsible_id"], name: "index_indicator_histories_on_responsible_id", using: :btree

  create_table "indicators", force: :cascade do |t|
    t.string   "name",                                null: false
    t.decimal  "value"
    t.text     "description"
    t.string   "frequency"
    t.date     "next_update"
    t.decimal  "goal",                default: 100.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "objective_id",                        null: false
    t.integer  "area_id",                             null: false
    t.integer  "ind_pos"
    t.date     "last_update"
    t.decimal  "last_value"
    t.integer  "responsible_id"
    t.integer  "company_id",                          null: false
    t.boolean  "reminder",            default: true,  null: false
    t.decimal  "worst_value",         default: 0.0
    t.boolean  "show_on_parent",      default: false, null: false
    t.string   "type"
    t.integer  "creator_id"
    t.integer  "hoshin_id",                           null: false
    t.boolean  "show_on_charts",      default: true,  null: false
    t.integer  "parent_area_id"
    t.integer  "parent_objective_id"
    t.datetime "deleted_at"
    t.boolean  "hidden",              default: false, null: false
  end

  add_index "indicators", ["area_id"], name: "index_indicators_on_area_id", using: :btree
  add_index "indicators", ["company_id"], name: "index_indicators_on_company_id", using: :btree
  add_index "indicators", ["creator_id"], name: "index_indicators_on_creator_id", using: :btree
  add_index "indicators", ["deleted_at"], name: "index_indicators_on_deleted_at", using: :btree
  add_index "indicators", ["hoshin_id"], name: "index_indicators_on_hoshin_id", using: :btree
  add_index "indicators", ["objective_id"], name: "index_indicators_on_objective_id", using: :btree
  add_index "indicators", ["parent_area_id"], name: "index_indicators_on_parent_area_id", using: :btree
  add_index "indicators", ["parent_objective_id"], name: "index_indicators_on_parent_objective_id", using: :btree
  add_index "indicators", ["responsible_id"], name: "index_indicators_on_responsible_id", using: :btree
  add_index "indicators", ["type"], name: "index_indicators_on_type", using: :btree

  create_table "invitation_codes", force: :cascade do |t|
    t.string   "name",       null: false
    t.integer  "total",      null: false
    t.integer  "used",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "trial_days", null: false
    t.date     "start_at",   null: false
    t.date     "end_at",     null: false
    t.integer  "partner_id"
  end

  add_index "invitation_codes", ["partner_id"], name: "index_invitation_codes_on_partner_id", using: :btree

  create_table "invoices", force: :cascade do |t|
    t.string   "sage_one_invoice_id"
    t.string   "description"
    t.decimal  "total_amount",        precision: 8, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "subscription_id"
    t.decimal  "net_amount",          precision: 8, scale: 2
    t.decimal  "tax_tpc",             precision: 8, scale: 2
  end

  add_index "invoices", ["subscription_id"], name: "index_invoices_on_subscription_id", using: :btree

  create_table "logs", force: :cascade do |t|
    t.string   "title"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id",   null: false
    t.integer  "creator_id"
    t.integer  "hoshin_id"
    t.integer  "area_id"
    t.integer  "goal_id"
    t.integer  "objective_id"
    t.integer  "indicator_id"
    t.string   "type"
    t.integer  "task_id"
    t.string   "operation",    null: false
  end

  add_index "logs", ["area_id"], name: "index_logs_on_area_id", using: :btree
  add_index "logs", ["company_id"], name: "index_logs_on_company_id", using: :btree
  add_index "logs", ["creator_id"], name: "index_logs_on_creator_id", using: :btree
  add_index "logs", ["goal_id"], name: "index_logs_on_goal_id", using: :btree
  add_index "logs", ["hoshin_id"], name: "index_logs_on_hoshin_id", using: :btree
  add_index "logs", ["indicator_id"], name: "index_logs_on_indicator_id", using: :btree
  add_index "logs", ["objective_id"], name: "index_logs_on_objective_id", using: :btree
  add_index "logs", ["task_id"], name: "index_logs_on_task_id", using: :btree
  add_index "logs", ["type"], name: "index_logs_on_type", using: :btree

  create_table "milestones", force: :cascade do |t|
    t.decimal  "value"
    t.date     "date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "objectives", force: :cascade do |t|
    t.string   "name",                           null: false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "area_id",                        null: false
    t.integer  "hoshin_id",                      null: false
    t.integer  "obj_pos"
    t.integer  "parent_id"
    t.integer  "responsible_id"
    t.integer  "company_id",                     null: false
    t.integer  "creator_id"
    t.boolean  "neglected",      default: false
    t.boolean  "blind",          default: true
    t.datetime "deleted_at"
    t.boolean  "hidden",         default: false, null: false
  end

  add_index "objectives", ["area_id"], name: "index_objectives_on_area_id", using: :btree
  add_index "objectives", ["company_id"], name: "index_objectives_on_company_id", using: :btree
  add_index "objectives", ["creator_id"], name: "index_objectives_on_creator_id", using: :btree
  add_index "objectives", ["deleted_at"], name: "index_objectives_on_deleted_at", using: :btree
  add_index "objectives", ["hoshin_id"], name: "index_objectives_on_hoshin_id", using: :btree
  add_index "objectives", ["parent_id"], name: "index_objectives_on_parent_id", using: :btree
  add_index "objectives", ["responsible_id"], name: "index_objectives_on_responsible_id", using: :btree

  create_table "partners", force: :cascade do |t|
    t.string   "name"
    t.string   "slug"
    t.integer  "companies_trial_days",    default: 90
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "creator_id"
    t.string   "email_logo_file_name"
    t.string   "email_logo_content_type"
    t.integer  "email_logo_file_size"
    t.datetime "email_logo_updated_at"
  end

  add_index "partners", ["creator_id"], name: "index_partners_on_creator_id", using: :btree
  add_index "partners", ["deleted_at"], name: "index_partners_on_deleted_at", using: :btree

  create_table "payment_notifications", force: :cascade do |t|
    t.string   "response"
    t.text     "raw_post"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "paypal_buttons", force: :cascade do |t|
    t.string   "product"
    t.string   "id_paypal"
    t.string   "id_paypal_sandbox"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "paypal_buttons", ["product"], name: "index_paypal_buttons_on_product", unique: true, using: :btree

  create_table "sage_ones", force: :cascade do |t|
    t.string   "access_token"
    t.datetime "expires_at"
    t.string   "refresh_token"
    t.string   "scopes"
    t.string   "requested_by_id"
    t.string   "resource_owner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "status",                                    default: "Active"
    t.boolean  "sandbox"
    t.integer  "company_id"
    t.decimal  "amount_value",      precision: 8, scale: 2
    t.string   "amount_currency"
    t.string   "id_paypal"
    t.datetime "deleted_at"
    t.string   "type"
    t.string   "deleted_by"
    t.integer  "users"
    t.decimal  "monthly_value",     precision: 8, scale: 2
    t.string   "billing_period"
    t.integer  "billing_detail_id"
    t.string   "plan_name"
    t.integer  "billing_plan_id"
    t.datetime "last_payment_at"
    t.date     "next_payment_at"
    t.datetime "paying_at"
    t.text     "payment_error"
    t.boolean  "per_user",                                  default: true,     null: false
  end

  add_index "subscriptions", ["billing_detail_id"], name: "index_subscriptions_on_billing_detail_id", using: :btree
  add_index "subscriptions", ["billing_plan_id"], name: "index_subscriptions_on_billing_plan_id", using: :btree
  add_index "subscriptions", ["company_id"], name: "index_subscriptions_on_company_id", using: :btree
  add_index "subscriptions", ["deleted_at"], name: "index_subscriptions_on_deleted_at", using: :btree
  add_index "subscriptions", ["type"], name: "index_subscriptions_on_type", using: :btree
  add_index "subscriptions", ["user_id"], name: "index_subscriptions_on_user_id", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string   "label"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "hoshin_id",    null: false
    t.integer  "creator_id"
    t.integer  "area_id"
    t.integer  "goal_id"
    t.integer  "objective_id"
    t.integer  "indicator_id"
    t.integer  "task_id"
    t.string   "type"
  end

  add_index "tags", ["area_id"], name: "index_tags_on_area_id", using: :btree
  add_index "tags", ["creator_id"], name: "index_tags_on_creator_id", using: :btree
  add_index "tags", ["goal_id"], name: "index_tags_on_goal_id", using: :btree
  add_index "tags", ["hoshin_id", "label"], name: "index_tags_on_hoshin_id_and_label", using: :btree
  add_index "tags", ["hoshin_id"], name: "index_tags_on_hoshin_id", using: :btree
  add_index "tags", ["indicator_id"], name: "index_tags_on_indicator_id", using: :btree
  add_index "tags", ["objective_id"], name: "index_tags_on_objective_id", using: :btree
  add_index "tags", ["task_id"], name: "index_tags_on_task_id", using: :btree
  add_index "tags", ["type"], name: "index_tags_on_type", using: :btree

  create_table "tasks", force: :cascade do |t|
    t.string   "name",                                    null: false
    t.text     "description"
    t.date     "deadline"
    t.date     "original_deadline"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "objective_id",                            null: false
    t.string   "status",              default: "backlog"
    t.datetime "key_timestamp"
    t.integer  "tsk_pos"
    t.integer  "area_id",                                 null: false
    t.boolean  "show_on_parent"
    t.string   "type"
    t.integer  "responsible_id"
    t.integer  "company_id",                              null: false
    t.boolean  "reminder",            default: true
    t.integer  "creator_id"
    t.integer  "hoshin_id",                               null: false
    t.integer  "lane_pos",            default: 0,         null: false
    t.integer  "parent_area_id"
    t.integer  "parent_objective_id"
    t.string   "feeling",             default: "smile",   null: false
    t.datetime "deleted_at"
    t.float    "confidence"
    t.float    "impact"
    t.float    "effort"
    t.integer  "visible_days",        default: 110,       null: false
    t.boolean  "hidden",              default: false,     null: false
  end

  add_index "tasks", ["area_id", "status"], name: "index_tasks_on_area_id_and_status", using: :btree
  add_index "tasks", ["area_id"], name: "index_tasks_on_area_id", using: :btree
  add_index "tasks", ["company_id"], name: "index_tasks_on_company_id", using: :btree
  add_index "tasks", ["creator_id"], name: "index_tasks_on_creator_id", using: :btree
  add_index "tasks", ["deadline", "status"], name: "index_tasks_on_deadline_and_status", using: :btree
  add_index "tasks", ["deleted_at"], name: "index_tasks_on_deleted_at", using: :btree
  add_index "tasks", ["hoshin_id", "status"], name: "index_tasks_on_hoshin_id_and_status", using: :btree
  add_index "tasks", ["hoshin_id"], name: "index_tasks_on_hoshin_id", using: :btree
  add_index "tasks", ["objective_id"], name: "index_tasks_on_objective_id", using: :btree
  add_index "tasks", ["parent_area_id"], name: "index_tasks_on_parent_area_id", using: :btree
  add_index "tasks", ["parent_objective_id"], name: "index_tasks_on_parent_objective_id", using: :btree
  add_index "tasks", ["responsible_id"], name: "index_tasks_on_responsible_id", using: :btree
  add_index "tasks", ["status"], name: "index_tasks_on_status", using: :btree
  add_index "tasks", ["type"], name: "index_tasks_on_type", using: :btree

  create_table "uri_dir_reports", force: :cascade do |t|
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_companies", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "company_id"
    t.string   "state"
    t.datetime "key_timestamp"
    t.integer  "roles_mask",    default: 7, null: false
  end

  add_index "user_companies", ["company_id"], name: "index_user_companies_on_company_id", using: :btree
  add_index "user_companies", ["state"], name: "index_user_companies_on_state", using: :btree
  add_index "user_companies", ["user_id", "company_id"], name: "index_user_companies_on_user_id_and_company_id", using: :btree
  add_index "user_companies", ["user_id"], name: "index_user_companies_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "crypted_password",          limit: 40
    t.string   "salt",                      limit: 40
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "name"
    t.string   "email_address"
    t.boolean  "administrator",                        default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state",                                default: "inactive"
    t.datetime "key_timestamp"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "tutorial_step"
    t.string   "timezone"
    t.string   "color"
    t.string   "language"
    t.datetime "last_login_at"
    t.integer  "login_count"
    t.string   "preferred_view",                       default: "expanded"
    t.date     "last_seen_at"
    t.integer  "subscriptions_count",                  default: 0,          null: false
    t.string   "firstName"
    t.string   "lastName"
    t.boolean  "beta_access"
    t.boolean  "news",                                 default: false
    t.boolean  "from_invitation",                      default: false
    t.date     "trial_ends_at"
    t.string   "invitation_code"
    t.string   "initial_task_state",                   default: "backlog",  null: false
    t.datetime "trial_ending_email"
    t.datetime "trial_ended_email"
    t.integer  "companies_trial_days",                 default: 0
    t.boolean  "notify_on_assign"
    t.integer  "partner_id"
  end

  add_index "users", ["email_address"], name: "index_users_on_email_address", unique: true, using: :btree
  add_index "users", ["partner_id"], name: "index_users_on_partner_id", using: :btree
  add_index "users", ["state"], name: "index_users_on_state", using: :btree

  add_foreign_key "flipper_gates", "flipper_features", on_delete: :cascade
end
