json.array!(@observation_matrices) do |matrix|
  json.partial! '/observation_matrices/api/v1/attributes', observation_matrix: matrix 
end
