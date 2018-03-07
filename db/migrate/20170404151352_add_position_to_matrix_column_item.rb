class AddPositionToMatrixColumnItem < ActiveRecord::Migration[4.2]
  def change
    add_column :matrix_column_items, :position, :integer
  end
end
