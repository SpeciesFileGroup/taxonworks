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

    i = 0
    batches = (DatasetRecord.count + BATCH_SIZE - 1) / BATCH_SIZE
    sha_lut = {}
    loop do
      start_time = Time.now
      dataset_records = DatasetRecord
        .limit(BATCH_SIZE).offset(BATCH_SIZE*i)
        .order(:import_dataset_id, :type, :id)
        .pluck(:id, :data_fields, :created_at, :updated_at, :created_by_id, :updated_by_id, :project_id, :import_dataset_id, :type)

      break if dataset_records.empty?

      dataset_records.each do |dataset_record|
        attributes = dataset_record[1].map.with_index do |data_field, position|
          {
            position: position,
            value: data_field["value"],
            dataset_record_id: dataset_record[0],
            project_id: dataset_record[6],
            import_dataset_id: dataset_record[7],
            encoded_dataset_record_type: sha_lut[dataset_record[8]] ||= Digest::MD5.hexdigest(dataset_record[8]).last(32/4).to_i(16) & (2**31 - 1)
          } if data_field["value"]
        end.compact

        DatasetRecordField.insert_all(attributes) if attributes.any?
      end

      i += 1
      print "\r#{i}/#{batches} batch(es) of #{BATCH_SIZE} records migrated. Last batch took #{((Time.now - start_time)*1000).to_i}ms."
    end

    remove_column :dataset_records, :data_fields    
  end
end
