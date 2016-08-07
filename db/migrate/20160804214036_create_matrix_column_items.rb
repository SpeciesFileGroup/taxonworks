class CreateMatrixColumnItems < ActiveRecord::Migration
  def change
    create_table :matrix_column_items do |t|
      t.references :matrix, index: true, foreign_key: true, null: false
      t.string :type, null: false
      t.references :descriptor, index: true, foreign_key: true
      t.references :controlled_vocabulary_term, index: true, foreign_key: true
      t.integer :created_by_id, null: false, index: true
      t.integer :updated_by_id, null: false, index: true
      t.references :project, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end

    add_foreign_key :matrix_column_items, :users, column: :created_by_id
    add_foreign_key :matrix_column_items, :users, column: :updated_by_id
  end
end
