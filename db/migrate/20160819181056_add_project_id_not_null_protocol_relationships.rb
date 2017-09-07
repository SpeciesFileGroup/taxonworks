class AddProjectIdNotNullProtocolRelationships < ActiveRecord::Migration[4.2]
  def change
    change_column_null :protocol_relationships, :project_id, false
  end
end
