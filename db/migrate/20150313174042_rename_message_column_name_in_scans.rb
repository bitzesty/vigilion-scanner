class RenameMessageColumnNameInScans < ActiveRecord::Migration
  def change
    rename_column :scans, :message, :result
  end
end
