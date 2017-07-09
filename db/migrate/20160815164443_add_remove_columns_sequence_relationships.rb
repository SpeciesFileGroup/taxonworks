class AddRemoveColumnsSequenceRelationships < ActiveRecord::Migration
  def change
    remove_column :sequence_relationships, :subject_sequence_type
    remove_column :sequence_relationships, :relationship_type
    remove_column :sequence_relationships, :object_sequence_type
    remove_column :sequence_relationships, :project_id

    add_column :sequence_relationships, :project_id, :integer, null: false
    add_column :sequence_relationships, :type, :string, null: false

    add_foreign_key :sequence_relationships, :sequences, column: :subject_sequence_id
    add_foreign_key :sequence_relationships, :sequences, column: :object_sequence_id

    add_foreign_key :sequence_relationships, :users, column: :created_by_id
    add_foreign_key :sequence_relationships, :users, column: :updated_by_id
  end
end
