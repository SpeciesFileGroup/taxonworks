class CreateDatasetRecordFields < ActiveRecord::Migration[6.0]
  BATCH_SIZE = 10000

  def change
    create_table :dataset_record_fields do |t|
      t.integer :position, null: false
      t.boolean :frozen_value, null: false
      t.string :value
      t.string :original_value

      t.string :dataset_record_type, null: false

      t.timestamps

      t.integer :created_by_id, null: false, index: true
      t.integer :updated_by_id, null: false, index: true
  
      t.references :project, index: true, foreign_key: true
      t.references :import_dataset, foreign_key: true
      t.references :dataset_record, foreign_key: true
      t.index [:dataset_record_id, :position], unique: true

      # Had to supply name because auto-generated one exceeds maximum length
      #t.index [:import_dataset_id, :position, :value, :dataset_record_id], unique: true, name: "index_dataset_record_fields_for_filters"
    
      # Index cannot be of arbitrary size, so limiting value length before indexing:
      t.index "import_dataset_id, dataset_record_type, position, substr(value, 1, 1000), dataset_record_id",
        name: "index_dataset_record_fields_for_filters", unique: true
    end

    i = 0
    batches = (DatasetRecord.count + BATCH_SIZE - 1) / BATCH_SIZE
    loop do
      dataset_records = DatasetRecord
        .limit(BATCH_SIZE).offset(BATCH_SIZE*i)
        .order(:import_dataset_id, :type, :id)
        .pluck(:id, :data_fields, :created_at, :updated_at, :created_by_id, :updated_by_id, :project_id, :import_dataset_id, :type)

      break if dataset_records.empty?

      dataset_records.each do |dataset_record|
        DatasetRecordField.insert_all(
          dataset_record[1].map.with_index do |data_field, position|
            {
              position: position,
              frozen_value: data_field["frozen"],
              value: data_field["value"],
              original_value: data_field["original_value"]
            }.merge!(
              dataset_record_id: dataset_record[0],
              created_at: dataset_record[2],
              updated_at: dataset_record[3],
              created_by_id: dataset_record[4],
              updated_by_id: dataset_record[5],
              project_id: dataset_record[6],
              import_dataset_id: dataset_record[7],
              dataset_record_type: dataset_record[8]
            )
          end
        )
      end

      i += 1
      print "\r#{i}/#{batches} batch(es) of #{BATCH_SIZE} records migrated."
    end

    remove_column :dataset_records, :data_fields    
  end
end
