class AddScans < ActiveRecord::Migration
  def change
    enable_extension 'uuid-ossp' unless extension_enabled?('uuid-ossp')
    create_table :scans, id: :uuid, default: 'uuid_generate_v4()' do |t|
      t.string :url, null: false
      t.integer :status, default: 0
      t.integer :duration, default: 0
      t.string :message
      t.string :md5
      t.string :sha1
      t.datetime :created_at, null: false
    end
  end
end
