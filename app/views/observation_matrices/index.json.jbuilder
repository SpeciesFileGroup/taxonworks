json.array!(@observation_matrices) do |matrix|
  json.partial! '/observation_matrices/attributes', observation_matrix: matrix 
end
