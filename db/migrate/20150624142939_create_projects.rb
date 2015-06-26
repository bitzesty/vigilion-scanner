class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.references :account, index: true, foreign_key: true
      t.string :plan
      t.string :callback_url
      t.string :heroku_id
      t.string :region
      t.text :options
      t.string :name

      t.string :access_key_id
      t.string :encrypted_secret_access_key

      t.timestamps null: false
    end
  end
end
