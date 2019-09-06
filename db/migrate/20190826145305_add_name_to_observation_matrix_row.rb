class AddNameToObservationMatrixRow < ActiveRecord::Migration[5.2]
  def change
    add_column :observation_matrix_rows, :name, :string
  end
end
