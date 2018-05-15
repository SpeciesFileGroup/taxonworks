case row_object.metamorphosize.class.name 
when 'Otu'
  json.partial! '/otus/attributes', otu: row_object 
when 'CollectionObject'
  json.partial! '/collection_objects/attributes', collection_object: row_object 
else
  raise
end
