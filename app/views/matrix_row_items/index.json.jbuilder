json.array!(@matrix_row_items) do |matrix_row_item|
  json.extract! matrix_row_item, :id, :matrix_id, :type, :collection_object_id, :otu_id, :controlled_vocabulary_term_id, :created_by_id, :updated_by_id, :project_id
  json.url matrix_row_item_url(matrix_row_item, format: :json)
end
