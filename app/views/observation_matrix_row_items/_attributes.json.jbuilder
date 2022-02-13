json.extract! observation_matrix_row_item, :id, :observation_matrix_id, :type, :observation_object_type, :observation_object_id, :controlled_vocabulary_term_id,
  :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at, :position
json.is_dynamic observation_matrix_row_item.is_dynamic?
json.partial! '/shared/data/all/metadata', object: observation_matrix_row_item 

