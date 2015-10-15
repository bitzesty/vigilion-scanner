class AddForeignKeys < ActiveRecord::Migration
  def change
    add_foreign_key :accounts, :plans
    add_foreign_key :projects, :accounts
    add_foreign_key :scans, :projects
  end
end
