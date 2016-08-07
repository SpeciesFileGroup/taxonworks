class AddReferenceCountToMatrixColumn < ActiveRecord::Migration
  def change
    add_column :matrix_columns, :reference_count, :integer
  end
end
