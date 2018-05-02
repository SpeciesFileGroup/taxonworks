json.extract! observation_matrix_column_item, :id, :observation_matrix_id, :type, :descriptor_id, :controlled_vocabulary_term_id,
  :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at, :position
json.is_dynamic observation_matrix_column_item.is_dynamic?
