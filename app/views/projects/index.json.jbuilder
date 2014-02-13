json.array!(@projects) do |project|
  json.extract! project, :id, :name, :created_by_id, :updated_by_id
  json.url project_url(project, format: :json)
end
