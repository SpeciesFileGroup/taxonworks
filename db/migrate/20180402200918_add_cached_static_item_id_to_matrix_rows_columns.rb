class AddCachedStaticItemIdToMatrixRowsColumns < ActiveRecord::Migration[5.1]
  def change
    add_column :observation_matrix_rows, :cached_observation_matrix_row_item_id, :integer
    add_column :observation_matrix_columns, :cached_observation_matrix_column_item_id, :integer
  end
end
