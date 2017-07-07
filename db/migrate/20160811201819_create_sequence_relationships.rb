class CreateSequenceRelationships < ActiveRecord::Migration
  def change
    create_table :sequence_relationships do |t|
      t.references :subject_sequence, polymorphic: true, null: false
      t.string :relationship_type
      t.references :object_sequence, polymorphic: true, null: false
      t.integer :created_by_id, null: false
      t.integer :updated_by_id, null: false
      t.references :project, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
