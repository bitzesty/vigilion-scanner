class AddForeignKeys < ActiveRecord::Migration[4.2]
  def change
    add_foreign_key :accounts, :plans
    add_foreign_key :projects, :accounts
    add_foreign_key :scans, :projects
  end
end
