json.array!(@observation_matrix_rows) do |observation_matrix_row|
  json.extract! observation_matrix_row, :id, :observation_matrix_id, :otu_id, :collection_object_id, 
    :position, :created_by_id, :updated_by_id, :project_id

  json.url observation_matrix_row_url(observation_matrix_row, format: :json)

  json.observation_matrix_row_object_global_id observation_matrix_row.row_object.to_global_id.to_s
  json.observation_matrix_row_object_label object_tag(observation_matrix_row.row_object)
end
