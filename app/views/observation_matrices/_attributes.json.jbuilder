json.extract! observation_matrix, :id, :name, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at
json.partial! '/shared/data/all/metadata', object: observation_matrix 
json.is_media_matrix observation_matrix.is_media_matrix?

