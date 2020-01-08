json.extract! download, :id, :name, :description, :filename, :expires, :times_downloaded, :created_at, :updated_at
json.url download_url(download, format: :json)
