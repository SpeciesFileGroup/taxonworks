json.array!(@matrix_rows) do |matrix_row|
  json.extract! matrix_row, :id, :matrix_id, :otu_id, :collection_object_id, :position, :created_by_id, :updated_by_id, :project_id
  json.url matrix_row_url(matrix_row, format: :json)
end
