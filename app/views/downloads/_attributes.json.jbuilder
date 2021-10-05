json.extract! download, :id, :name, :description, :request, :expires, :times_downloaded, :total_records, :is_public, :type, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at
json.ready download.ready?
json.file_url file_download_url(download)
json.partial! '/shared/data/all/metadata', object: download 

