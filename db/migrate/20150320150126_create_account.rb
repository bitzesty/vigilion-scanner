class CreateAccount < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :name
      t.string :api_key
      t.string :callback_url
    end

    add_index(:accounts, [:name, :callback_url, :api_key], unique: true)
  end
end
