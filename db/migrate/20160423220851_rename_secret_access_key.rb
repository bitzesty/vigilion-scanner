class RenameSecretAccessKey < ActiveRecord::Migration[5.0]
  def change
    rename_column :projects, :encrypted_secret_access_key, :secret_access_key
  end
end
