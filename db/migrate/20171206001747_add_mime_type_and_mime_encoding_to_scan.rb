class AddMimeTypeAndMimeEncodingToScan < ActiveRecord::Migration[5.0]
  def change
    add_column :scans, :mime_type, :string
    add_column :scans, :mime_encoding, :string
  end
end
