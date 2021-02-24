json.extract! observation_matrix_column, :id, :observation_matrix_id, :descriptor_id, :reference_count, :position, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at
json.cached_observation_matrix_column_item_id observation_matrix_column_destroyable?(observation_matrix_column)

json.descriptor do
  json.partial! '/descriptors/attributes', descriptor: observation_matrix_column.descriptor
end



