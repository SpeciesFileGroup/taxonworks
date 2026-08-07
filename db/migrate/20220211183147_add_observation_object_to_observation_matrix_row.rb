class AddObservationObjectToObservationMatrixRow < ActiveRecord::Migration[6.1]
  def change
    add_column :observation_matrix_rows, :observation_object_id, :integer
    add_column :observation_matrix_rows, :observation_object_type, :string
    add_index :observation_matrix_rows, [:observation_object_id, :observation_object_type], name: 'obmxrow_polymorphic_obj_index'
  end
end
