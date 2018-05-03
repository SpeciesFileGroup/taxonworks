json.array!(@observation_matrix_rows) do |observation_matrix_row|
  json.partial! 'attributes', observation_matrix_row: observation_matrix_row
end
