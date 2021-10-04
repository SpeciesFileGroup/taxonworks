class AddIdToDatasetRecordIndex < ActiveRecord::Migration[6.0]
  def change
    remove_index :dataset_records, [:import_dataset_id, :type]
    add_index :dataset_records, [:import_dataset_id, :type, :id]
  end
end
