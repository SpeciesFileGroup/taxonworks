class AddProjectIdFkToSequenceRelationships < ActiveRecord::Migration[4.2]
  def change
    add_foreign_key :sequence_relationships, :projects, column: :project_id
  end
end
