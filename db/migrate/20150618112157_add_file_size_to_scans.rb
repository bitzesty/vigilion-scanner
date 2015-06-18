class AddFileSizeToScans < ActiveRecord::Migration
  def change
    add_column :scans, :file_size, :integer, limit: 8
  end
end
