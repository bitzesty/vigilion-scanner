class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :name
      t.string :callback_url
      t.string :access_key_id
      t.string :encrypted_secret_access_key

      t.timestamps null: false
    end
  end
end
