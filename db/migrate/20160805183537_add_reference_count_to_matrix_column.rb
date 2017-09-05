class AddReferenceCountToMatrixColumn < ActiveRecord::Migration[4.2]
  def change
    add_column :matrix_columns, :reference_count, :integer
  end
end
