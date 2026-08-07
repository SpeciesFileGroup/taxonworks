json.extract! sequence, :id, :sequence, :name, :sequence_type, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at

json.partial! '/shared/data/all/metadata', object: sequence

