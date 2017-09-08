class AddProjectIdNotNullProtocols < ActiveRecord::Migration[4.2]
  def change
    change_column_null :protocols, :project_id, false
  end
end
