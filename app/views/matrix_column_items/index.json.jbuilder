json.array!(@matrix_column_items) do |matrix_column_item|
  json.extract! matrix_column_item, :id, :matrix_id, :type, :descriptor_id, :keyword_id, :created_by_id, :updated_by_id, :project_id
  json.url matrix_column_item_url(matrix_column_item, format: :json)
end
