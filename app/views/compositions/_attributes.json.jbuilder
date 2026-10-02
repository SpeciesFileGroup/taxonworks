json.extract! composition, :id, :type, :name, :description, :version, :is_community, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at
json.partial! '/shared/data/all/metadata', object: composition
