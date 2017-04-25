class SetExistingScansToDefault < ActiveRecord::Migration[5.0]
  def up
    say_with_time "set all existing scans to clamav by default" do
      Scan.find_each do |scan|
        scan.clamav_status = scan.status
        scan.clamav_result = scan.result
        scan.save
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "all scans have already been set to clamav!"
  end
end
