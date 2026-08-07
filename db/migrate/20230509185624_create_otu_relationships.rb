class CreateOtuRelationships < ActiveRecord::Migration[6.1]
  def change
    create_table :otu_relationships do |t|
      t.integer :subject_otu_id, null: false, index: true
      t.string :type, null: false
      t.integer :object_otu_id, null: false, index: true
      t.references :project, foreign_key: true

      t.integer :created_by_id, null: false, index: true
      t.integer :updated_by_id, null: false, index: true

      t.timestamps
    end

    add_foreign_key :otu_relationships, :otus, column: :subject_otu_id, primary_key: :id
    add_foreign_key :otu_relationships, :otus, column: :object_otu_id, primary_key: :id

    add_foreign_key :otu_relationships, :users, column: :created_by_id, primary_key: :id
    add_foreign_key :otu_relationships, :users, column: :updated_by_id, primary_key: :id


  end
end
