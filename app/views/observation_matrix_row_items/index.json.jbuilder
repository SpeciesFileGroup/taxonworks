json.array!(@observation_matrix_row_items) do |observation_matrix_row_item|
  json.partial! '/observation_matrix_row_items/attributes', observation_matrix_row_item: observation_matrix_row_item
end
