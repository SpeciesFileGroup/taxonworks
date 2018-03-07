@collection_objects.each_key do |group|
  json.set!(group) do
    json.array! @collection_objects[group] do |o|
      json.partial! '/collection_objects/attributes', collection_object: o 
    end
  end
end
