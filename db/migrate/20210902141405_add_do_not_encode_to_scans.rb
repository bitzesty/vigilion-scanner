class AddDoNotEncodeToScans < ActiveRecord::Migration[5.0]
  def change
    change_table "scans" do |t|
      t.boolean :do_not_unencode, null: false, default: false
    end
  end
end
