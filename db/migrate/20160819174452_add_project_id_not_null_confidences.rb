class AddProjectIdNotNullConfidences < ActiveRecord::Migration[4.2]
  def change
    change_column_null :confidences, :project_id, false
  end
end
