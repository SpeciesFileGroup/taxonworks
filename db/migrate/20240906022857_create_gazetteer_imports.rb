class CreateGazetteerImports < ActiveRecord::Migration[7.1]
  def change
    create_table :gazetteer_imports do |t|

      t.string :shapefile
      t.integer :num_records
      t.integer :num_records_processed
      t.string :aborted_reason
      t.datetime :started_at
      t.datetime :ended_at

      t.references :project, index: true, foreign_key: true
      t.timestamps null: false

      t.integer :created_by_id, null: false, index: true
      t.integer :updated_by_id, null: false, index: true
    end
  end
end
