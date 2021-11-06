class AddTotalRecordsToDownloads < ActiveRecord::Migration[6.1]
  def change
    add_column :downloads, :total_records, :integer
  end
end
