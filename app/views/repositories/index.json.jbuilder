json.array!(@repositories) do |repository|
  json.extract! repository, :id, :name, :url, :acronym, :status, :institutional_LSID, :is_index_herbariorum, :created_by_id, :updated_by_id
  json.url repository_url(repository, format: :json)
end
