class ChangeScans < ActiveRecord::Migration
  def change
    change_table :scans do |t|
      t.string  :uuid, null: false
    end

    add_index :scans, :uuid, unique: true
  end
end
