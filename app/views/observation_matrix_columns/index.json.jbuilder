json.array!(@observation_matrix_columns) do |observation_matrix_column|
  json.partial! '/observation_matrix_columns/attributes', observation_matrix_column: observation_matrix_column
end
