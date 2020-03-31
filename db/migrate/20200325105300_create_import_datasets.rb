class CreateImportDatasets < ActiveRecord::Migration[6.0]
  def change
    create_table :import_datasets do |t|
      t.string :type, null: false
      t.string :status, null: false
      t.string :description, null: false
      t.jsonb :metadata

      t.timestamps null: false

      t.integer :created_by_id, null: false, index: true
      t.integer :updated_by_id, null: false, index: true

      t.references :project, index: true, foreign_key: true
    end

    add_attachment :import_datasets, :source
  end
end
