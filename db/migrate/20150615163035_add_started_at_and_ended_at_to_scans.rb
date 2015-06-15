class AddStartedAtAndEndedAtToScans < ActiveRecord::Migration
  def change
    add_column :scans, :started_at, :datetime
    add_column :scans, :ended_at, :datetime
    remove_column :scans, :duration
  end
end
