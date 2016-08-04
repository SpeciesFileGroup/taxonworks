json.array!(@matrix_columns) do |matrix_column|
  json.extract! matrix_column, :id, :matrix_id, :descriptor_id, :position, :created_by_id, :updated_by_id, :project_id
  json.url matrix_column_url(matrix_column, format: :json)
end
