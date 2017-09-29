json.extract! type_material, :id, :protonym_id, :biological_object_id, :type_type, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at
json.object_tag type_material_tag(type_material)
json.url type_material_url(type_material, format: :json)

if type_material.source 
  json.source do 
    json.partial! '/sources/attributes', source: type_material.source
  end
end

json.collection_object do 
  json.partial! '/collection_objects/attributes', collection_object: type_material.material
end

