json.extract! protocol, :id, :name, :short_name, :description, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at
json.partial! '/shared/data/all/metadata', object: protocol 
