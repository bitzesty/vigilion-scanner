class AllowNullScanUrl < ActiveRecord::Migration
  def change
    change_column :scans, :url, :string, null: true
  end
end
