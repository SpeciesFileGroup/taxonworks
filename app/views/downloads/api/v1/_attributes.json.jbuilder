json.extract! download, :id, :name, :type, :description, :filename, :times_downloaded, :request, :expires, :sha2, :created_at, :updated_at, :project_id

if download.persisted? && !download.expired?
  json.file api_v1_download_file_url(download)
end
