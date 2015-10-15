class InitialSchema < ActiveRecord::Migration
  def up
    enable_extension 'uuid-ossp'

    create_table :plans do |t|
      t.string  :name
      t.decimal :cost
      t.decimal :file_size_limit
      t.integer :scans_per_month
      t.boolean :available_for_new_subscriptions, null: false, default: true
      t.timestamps null: false
    end

    create_table "accounts" do |t|
      t.references  :plan, index: true, null: false
      t.boolean     :enabled, null: false, default: true
      t.timestamps  null: false
    end

    create_table "projects", id: :uuid, default: "uuid_generate_v4()" do |t|
      t.references :account, index: true, null: false
      t.string     :name
      t.string     :callback_url
      t.string     :access_key_id
      t.string     :encrypted_secret_access_key
      t.timestamps null: false
    end

    create_table "scans", id: :uuid, default: "uuid_generate_v4()" do |t|
      t.uuid   "project_id",  null: false
      t.string   "url"
      t.string   "key",         null: false
      t.boolean  "force",       default: false
      t.integer  "status",      default: 0
      t.string   "result"
      t.string   "md5"
      t.string   "sha1"
      t.string   "sha256"
      t.integer  "file_size",   limit: 8
      t.datetime "created_at",  null: false
      t.datetime "updated_at",  null: false
      t.datetime "started_at"
      t.datetime "ended_at"
    end

    add_index "scans", ["project_id"]
    add_index "scans", ["md5"]
  end
end
