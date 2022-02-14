# !! TODO: generalize to any class, probably in a helper method, and remove this
case observation_object.class.name
when 'Otu'
  json.partial! '/otus/attributes', otu: observation_object 
when 'CollectionObject'
  json.partial! '/collection_objects/attributes', collection_object: observation_object 
when 'Extract'
  json.partial! '/extracts/attributes', extract: observation_object 
else
  raise
end
