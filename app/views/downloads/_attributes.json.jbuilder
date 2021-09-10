json.extract! download, :id, :name, :description, :request, :expires, :times_downloaded, :is_public, :type, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at
json.ready download.ready?
json.partial! '/shared/data/all/metadata', object: download 

