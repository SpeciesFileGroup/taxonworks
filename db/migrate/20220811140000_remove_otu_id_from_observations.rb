class RemoveOtuIdFromObservations < ActiveRecord::Migration[4.2]
  def change
    remove_column :observations, :otu_id
    remove_column :observations, :collection_object_id
    remove_column :observation_matrix_row_items, :otu_id
    remove_column :observation_matrix_row_items, :collection_object_id
    remove_column :observation_matrix_rows, :otu_id
    remove_column :observation_matrix_rows, :collection_object_id

  end
end