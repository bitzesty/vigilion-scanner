class RemoveUuidUniqueness < ActiveRecord::Migration
  def change
    remove_index :scans, :uuid
  end
end
