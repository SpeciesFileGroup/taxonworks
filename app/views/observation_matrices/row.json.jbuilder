json.row_object do 
  case @observation_matrix_row.row_object_class_name 
  when 'Otu'
    json.partial! '/otus/attributes', otu: @observation_matrix_row.row_object 
  when 'CollectionObject'
    json.partial! '/collection_object/attributes', collection_object: @observation_matrix_row.row_object 
  else
    raise
  end
end

json.descriptors do |descriptors|
  descriptors.array!(@observation_matrix_row.observation_matrix.descriptors) do |descriptor|
    descriptors.partial! '/descriptors/attributes', descriptor: descriptor
  end
end




