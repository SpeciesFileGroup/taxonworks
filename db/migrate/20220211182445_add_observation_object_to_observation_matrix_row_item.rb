class AddObservationObjectToObservationMatrixRowItem < ActiveRecord::Migration[6.1]
  def change
    add_column :observation_matrix_row_items, :observation_object_id, :integer
    add_column :observation_matrix_row_items, :observation_object_type, :string
    add_index :observation_matrix_row_items, [:observation_object_id, :observation_object_type], name: 'omrowitem_oo_polymorphic_index'
  end
end
