class AddMd5IndexToScans < ActiveRecord::Migration
  def change
    add_index :scans, :md5
  end
end
