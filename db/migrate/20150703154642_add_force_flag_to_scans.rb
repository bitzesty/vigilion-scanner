class AddForceFlagToScans < ActiveRecord::Migration
  def change
    add_column :scans, :force, :boolean, default: false
  end
end
