json.id @observation_matrix_row.id

json.observation_object do
  json.partial! "/observation_matrices/observation_object", observation_object: @observation_matrix_row.observation_object
end

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
  descriptors.array!(@observation_matrix_row.observation_matrix.descriptors.includes(:observation_matrix_columns).order('observation_matrix_columns.position ASC')) do |descriptor|
    descriptors.partial! '/descriptors/attributes', descriptor: descriptor
  end
end
