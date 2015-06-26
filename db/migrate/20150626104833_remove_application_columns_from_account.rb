class RemoveApplicationColumnsFromAccount < ActiveRecord::Migration
  def up
    remove_column :accounts, :callback_url
    remove_column :accounts, :access_key_id
    remove_column :accounts, :encrypted_secret_access_key
  end

  def down
    add_column :accounts, :callback_url, :string
    add_column :accounts, :access_key_id, :string
    add_column :accounts, :encrypted_secret_access_key, :string
  end
end
