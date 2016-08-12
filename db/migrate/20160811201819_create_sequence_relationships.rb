class CreateSequenceRelationships < ActiveRecord::Migration
  def change
    create_table :sequence_relationships do |t|
      t.polymorphic :subject_sequence, foreign_key: true
      t.string :type
      t.polymorphic :object_sequence, foreign_key: true
      t.integer :created_by_id, null: false
      t.integer :updated_by_id, null: false
      t.references :project, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
