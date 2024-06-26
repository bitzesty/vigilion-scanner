# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_09_02_141405) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "accounts", id: :serial, force: :cascade do |t|
    t.integer "plan_id", null: false
    t.boolean "enabled", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "alert_email"
    t.string "name"
    t.index ["plan_id"], name: "index_accounts_on_plan_id"
  end

  create_table "plans", id: :serial, force: :cascade do |t|
    t.string "name"
    t.decimal "cost"
    t.decimal "file_size_limit"
    t.integer "scans_per_month"
    t.boolean "available_for_new_subscriptions", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "clamav", default: true
    t.boolean "eset", default: false
    t.boolean "avg", default: false
  end

  create_table "projects", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.integer "account_id", null: false
    t.string "name"
    t.string "callback_url"
    t.string "access_key_id"
    t.string "secret_access_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_projects_on_account_id"
  end

  create_table "scans", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "project_id", null: false
    t.string "url"
    t.string "key", null: false
    t.boolean "force", default: false
    t.integer "status", default: 0
    t.string "result"
    t.string "md5"
    t.string "sha1"
    t.string "sha256"
    t.bigint "file_size"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "started_at"
    t.datetime "ended_at"
    t.integer "clamav_status", default: 0
    t.integer "eset_status", default: 0
    t.integer "avg_status", default: 0
    t.string "clamav_result"
    t.string "eset_result"
    t.string "avg_result"
    t.string "mime_type"
    t.string "mime_encoding"
    t.text "webhook_response"
    t.boolean "do_not_unencode", default: false, null: false
    t.index ["md5"], name: "index_scans_on_md5"
    t.index ["project_id"], name: "index_scans_on_project_id"
  end

  add_foreign_key "accounts", "plans"
  add_foreign_key "projects", "accounts"
  add_foreign_key "scans", "projects"
end
