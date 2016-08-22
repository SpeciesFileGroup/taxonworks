class AddMissingColumnsToMatrixRowItems < ActiveRecord::Migration
  def change
    add_column :matrix_row_items, :position, :integer
    change_column_null :matrix_row_items, :project_id, false
  end
end
