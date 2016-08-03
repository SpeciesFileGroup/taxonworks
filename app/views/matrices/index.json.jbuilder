json.array!(@matrices) do |matrix|
  json.extract! matrix, :id, :name, :created_by_id, :updated_by_id, :project_id
  json.url matrix_url(matrix, format: :json)
end
