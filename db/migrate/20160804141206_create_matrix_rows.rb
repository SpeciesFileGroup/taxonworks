class CreateMatrixRows < ActiveRecord::Migration
  def change
    create_table :matrix_rows do |t|
      t.references :matrix, null: false, index: true, foreign_key: true
      t.references :otu, index: true, foreign_key: true
      t.references :collection_object, index: true, foreign_key: true
      t.integer :position
      t.integer :created_by_id, null: false, index: true
      t.integer :updated_by_id, null: false, index: true
      t.references :project, null: false, index: true, foreign_key: true

      t.timestamps null: false
    end

    add_foreign_key :matrix_rows, :users, column: :created_by_id
    add_foreign_key :matrix_rows, :users, column: :updated_by_id
  end
end
