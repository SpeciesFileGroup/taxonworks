class AddNotNullConstratingToProjectIdForProjectSources < ActiveRecord::Migration
  def change
    change_column_null :project_sources, :project_id, false
  end
end
