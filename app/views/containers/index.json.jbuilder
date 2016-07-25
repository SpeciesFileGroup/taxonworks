json.array!(@containers) do |container|
  json.extract! container, :id, :parent_id, :type, :created_by_id, :updated_by_id, :project_id, :otu_id, :name, :disposition
  json.url container_url(container, format: :json)
end
