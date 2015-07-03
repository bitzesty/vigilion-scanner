class RenameAccountIdToProjectId < ActiveRecord::Migration
  def change
    rename_column :scans, :account_id, :project_id
  end
end
