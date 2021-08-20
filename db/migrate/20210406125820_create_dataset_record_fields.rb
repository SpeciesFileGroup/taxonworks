class CreateDatasetRecordFields < ActiveRecord::Migration[6.0]
  BATCH_SIZE = 10000

  def change
    create_table :dataset_record_fields do |t|
      t.integer :position, null: false
      t.string :value, null: false # Aproximately half of the fields are null at sandworm, makes sense to avoid storing them.
      # t.string :original_value # TODO: Keep this somewhere else. Consider storing at first change

      t.integer :encoded_dataset_record_type, null: false

      #t.timestamps # TODO: Forward to dataset record if important

      # TODO: If breaks something, attempt to wire these to corresponding dataset record
      #t.integer :created_by_id, null: false, index: false, type: :integer
      #t.integer :updated_by_id, null: false, index: false, type: :integer
  
      t.references :project, index: false, foreign_key: true, null: false, type: :integer # Only for security to prevent leaks (when exporting projects for example)
      t.references :import_dataset, index: false, foreign_key: true, null: false, type: :integer
      t.references :dataset_record, index: false, foreign_key: true, null: false
      t.index [:dataset_record_id, :position], unique: true # save more space. # Cannot save space, need this for upsert to work as the index below fails to be matched by ActiveRecord

      # Had to supply name because auto-generated one exceeds maximum length
      #t.index [:import_dataset_id, :position, :value, :dataset_record_id], unique: true, name: "index_dataset_record_fields_for_filters"
    
      # Index cannot be of arbitrary size, so limiting value length before indexing:
      t.index "import_dataset_id, encoded_dataset_record_type, position, substr(value, 1, 1000), dataset_record_id",
        name: "index_dataset_record_fields_for_filters", unique: true
    end

    remove_column :dataset_records, :data_fields    
  end
end
