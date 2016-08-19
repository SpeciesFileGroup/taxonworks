class AddProjectIdNotNullProtocols < ActiveRecord::Migration
  def change
    change_column_null :protocols, :project_id, false
  end
end
