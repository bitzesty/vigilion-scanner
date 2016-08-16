class AddMultipleAvScannersFieldsToScans < ActiveRecord::Migration[5.0]
  def change
    add_column :scans, :clamav, :boolean, default: false
    add_column :scans, :eset, :boolean, default: false
    add_column :scans, :avg, :boolean, default: false

    add_column :scans, :clamav_status, :integer, default: 0
    add_column :scans, :eset_status, :integer, default: 0
    add_column :scans, :avg_status, :integer, default: 0

    add_column :scans, :clamav_result, :string
    add_column :scans, :eset_result, :string
    add_column :scans, :avg_result, :string
  end
end
