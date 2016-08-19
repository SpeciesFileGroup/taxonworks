class AddProjectIdNotNullConfidences < ActiveRecord::Migration
  def change
    change_column_null :confidences, :project_id, false
  end
end
