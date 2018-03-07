json.array!(@observation_matrices) do |matrix|
  json.extract! matrix, :id, :name, :created_by_id, :updated_by_id, :project_id
  json.url observationMatrix_url(matrix, format: :json)
end
