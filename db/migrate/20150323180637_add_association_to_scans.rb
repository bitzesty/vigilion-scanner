class AddAssociationToScans < ActiveRecord::Migration
  def change
    change_table :scans do |t|
      t.references :account
    end
  end
end
