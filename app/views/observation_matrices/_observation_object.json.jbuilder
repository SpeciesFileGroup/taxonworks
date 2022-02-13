
# TODO: generalize to any class, probably in a helper method
case observation_object.metamorphosize.class.name 
when 'Otu'
  json.partial! '/otus/attributes', otu: observation_object 
when 'CollectionObject'
  json.partial! '/collection_objects/attributes', collection_object: observation_object 
else
  raise
end
