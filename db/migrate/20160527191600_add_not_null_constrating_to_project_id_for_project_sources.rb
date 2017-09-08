class AddNotNullConstratingToProjectIdForProjectSources < ActiveRecord::Migration[4.2]
  def change
    change_column_null :project_sources, :project_id, false
  end
end
