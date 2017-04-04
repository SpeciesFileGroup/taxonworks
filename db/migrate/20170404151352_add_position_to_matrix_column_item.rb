class AddPositionToMatrixColumnItem < ActiveRecord::Migration
  def change
    add_column :matrix_column_items, :position, :integer
  end
end
