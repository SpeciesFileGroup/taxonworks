class AddProjectIdFkToSequenceRelationships < ActiveRecord::Migration
  def change
    add_foreign_key :sequence_relationships, :projects, column: :project_id
  end
end
