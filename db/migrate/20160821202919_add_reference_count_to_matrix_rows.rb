class AddReferenceCountToMatrixRows < ActiveRecord::Migration[4.2]
  def change
    add_column :matrix_rows, :reference_count, :integer
  end
end
