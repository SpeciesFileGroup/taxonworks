json.extract! observation_matrix_row, :id, :observation_matrix_id, :otu_id, :collection_object_id, :position, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at,
  :cached_observation_matrix_row_item_id

json.row_object do
  json.partial! "/observation_matrices/row_object", row_object: observation_matrix_row.row_object
end

