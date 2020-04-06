class CreateDatasetRecords < ActiveRecord::Migration[6.0]
  def change
    create_table :dataset_records do |t|
      t.string :type, null: false
      t.string :status, null: false
      t.jsonb :data_fields, null: false
      t.jsonb :metadata

      t.timestamps

      t.integer :created_by_id, null: false, index: true
      t.integer :updated_by_id, null: false, index: true

      t.references :project, index: true, foreign_key: true
      t.references :import_dataset, index: true, foreign_key: true

      t.index [:import_dataset_id, :type]
    end
  end
end