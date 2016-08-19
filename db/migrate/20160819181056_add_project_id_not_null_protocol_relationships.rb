class AddProjectIdNotNullProtocolRelationships < ActiveRecord::Migration
  def change
    change_column_null :protocol_relationships, :project_id, false
  end
end
