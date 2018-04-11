json.row_object do |row_object|
  case @observation_matrix_row 
  when 'Otu'
    row_object.partial! '/otus/attributes', otu: row_object 
  when 'CollectionObject'
    row_object.partial! '/collection_object/attributes', collection_object: row_object 
  else
    raise
  end
end

json.descriptors do |descriptors|
  descriptors.array!(@observation_matrix_row.observation_matrix.descriptors) do |descriptor|
    descriptors.partial! '/descriptors/attributes', descriptor: descriptor
  end
end




