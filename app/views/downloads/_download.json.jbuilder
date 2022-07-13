json.extract! download, :id, :name, :description, :filename, :expires, :times_downloaded, :created_at, :updated_at
json.url download_url(download, format: :json)
json.ready download.ready?

json.api_file_url download_file_api_url(download)
json.file_url file_download_url(download)
