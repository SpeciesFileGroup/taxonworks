json.array!(@observation_matrix_column_items) do |observation_matrix_column_item|
  json.partial! '/observation_matrix_column_items/attributes', observation_matrix_column_item: observation_matrix_column_item
end
