json.extract! collection_object, :id, :total, :preparation_type_id, :collecting_event_id, :repository_id, :type, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at
json.partial! '/shared/data/all/metadata', object: collection_object 


