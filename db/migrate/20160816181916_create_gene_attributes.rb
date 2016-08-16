class CreateGeneAttributes < ActiveRecord::Migration
  def change
    create_table :gene_attributes do |t|
      #t.references :descriptor, index: true, foreign_key: true, null: false
      t.integer :descriptor_id, null: false
      t.references :sequence, index: true, foreign_key: true, null: false
      t.string :sequence_relationship_type
      t.references :controlled_vocabulary_term, index: true, foreign_key: true
      t.integer :position
      t.integer :created_by_id, null: false
      t.integer :updated_by_id, null: false
      t.references :project, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end
