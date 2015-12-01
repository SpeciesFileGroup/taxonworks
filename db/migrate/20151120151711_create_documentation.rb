class CreateDocumentation < ActiveRecord::Migration
  def change
    create_table :documentation do |t|
      t.references :documentation_object, polymorphic: true,  null: false
      t.references :document, index: true, foreign_key: true, null: false
      t.string  :type, index: true, null: false
      t.json :page_map
      t.references :project, index: true, foreign_key: true, null: false
      t.integer :created_by_id, index: true, null: false
      t.integer :updated_by_id, index: true, null: false

      t.timestamps null: false
    end
    
    add_foreign_key :documentation, :users, column: :created_by_id
    add_foreign_key :documentation, :users, column: :updated_by_id

    add_index :documentation, [:documentation_object_id, :documentation_object_type], name: :index_doc_on_doc_object_type_and_doc_object_id

  end
end
