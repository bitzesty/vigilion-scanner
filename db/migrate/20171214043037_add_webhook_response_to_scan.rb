class AddWebhookResponseToScan < ActiveRecord::Migration[5.0]
  def change
    change_table :scans do |t|
      t.text :webhook_response
    end
  end
end
