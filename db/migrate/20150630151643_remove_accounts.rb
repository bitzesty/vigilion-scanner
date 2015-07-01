class RemoveAccounts < ActiveRecord::Migration
  def up
    remove_foreign_key "projects", "accounts"
    drop_table :accounts
  end

  def down
    add_foreign_key "projects", "accounts"
    create_table :accounts do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
