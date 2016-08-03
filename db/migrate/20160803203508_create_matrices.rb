class CreateMatrices < ActiveRecord::Migration
  def change
    create_table :matrices do |t|
      t.string :name, null: false, index: true
      t.integer :created_by_id, null: false, index: true
      t.integer :updated_by_id, null: false, index: true
      t.references :project, index: true, foreign_key: true

      t.timestamps null: false
    end
    
    add_foreign_key :matrices, :users, column: :created_by_id
    add_foreign_key :matrices, :users, column: :updated_by_id
  end
end
