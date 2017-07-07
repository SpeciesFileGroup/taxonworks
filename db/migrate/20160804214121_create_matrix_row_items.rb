class CreateMatrixRowItems < ActiveRecord::Migration
  def change
    create_table :matrix_row_items do |t|
      t.references :matrix, null: false, index: true, foreign_key: true
      t.string :type, null: false
      t.references :collection_object, index: true, foreign_key: true
      t.references :otu, index: true, foreign_key: true
      t.references :controlled_vocabulary_term, index: true, foreign_key: true
      t.integer :created_by_id, null: false, index: true
      t.integer :updated_by_id, null: false, index: true
      t.references :project, index: true, foreign_key: true

      t.timestamps null: false
    end

  add_foreign_key :matrix_row_items, :users, column: :created_by_id
  add_foreign_key :matrix_row_items, :users, column: :updated_by_id
  end
end
