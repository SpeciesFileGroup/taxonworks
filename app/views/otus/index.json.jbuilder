json.array!(@otus) do |otu|
  json.extract! otu, :id, :name, :created_by_id, :updated_by_id, :project_id
  json.url otu_url(otu, format: :json)
end
