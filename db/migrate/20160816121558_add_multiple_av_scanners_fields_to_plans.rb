class AddMultipleAvScannersFieldsToPlans < ActiveRecord::Migration[5.0]
  def change
    add_column :plans, :clamav, :boolean, default: true
    add_column :plans, :eset, :boolean, default: false
    add_column :plans, :avg, :boolean, default: false
  end
end
