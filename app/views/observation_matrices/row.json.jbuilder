json.partial! "row_object", row_object: @observation_matrix_row.row_object

json.observation_matrix do
  json.partial! "/observation_matrices/attributes", observation_matrix: @observation_matrix_row.observation_matrix  
end

if a = @observation_matrix_row.next_row
  json.next_row do
    json.partial! "/observation_matrix_rows/attributes", observation_matrix_row:  a
  end
end

if a = @observation_matrix_row.previous_row
  json.previous_row do
    json.partial! "/observation_matrix_rows/attributes", observation_matrix_row: a
  end
end

json.descriptors do |descriptors|
  descriptors.array!(@observation_matrix_row.observation_matrix.descriptors) do |descriptor|
    descriptors.partial! '/descriptors/attributes', descriptor: descriptor
  end
end
