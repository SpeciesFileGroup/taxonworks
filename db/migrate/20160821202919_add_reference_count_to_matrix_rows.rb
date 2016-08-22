class AddReferenceCountToMatrixRows < ActiveRecord::Migration
  def change
    add_column :matrix_rows, :reference_count, :integer
  end
end
