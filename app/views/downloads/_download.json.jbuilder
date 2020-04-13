json.extract! download, :id, :name, :description, :filename, :expires, :times_downloaded, :created_at, :updated_at
json.url download_url(download, format: :json)

json.api_file_download_url download_api_url(download)
json.file_download_url download_file_download_url(download)
