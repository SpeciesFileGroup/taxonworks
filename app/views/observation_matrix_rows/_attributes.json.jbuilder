json.extract! observation_matrix_row, :id, :observation_matrix_id, :otu_id, :collection_object_id,
:position, :reference_count, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at

# Careful, we override this based on whether destroying a observation matrix row_item
# will destroy a corresponding row (it could persist for dyanamic reasons)
json.cached_observation_matrix_row_item_id observation_matrix_row_destroyable?(observation_matrix_row)

json.url observation_matrix_row_url(observation_matrix_row, format: :json)

json.observation_matrix_row_object_global_id observation_matrix_row.row_object.to_global_id.to_s
json.observation_matrix_row_object_label object_tag(observation_matrix_row.row_object)

json.row_object do
  json.partial! "/observation_matrices/row_object", row_object: observation_matrix_row.row_object
end

