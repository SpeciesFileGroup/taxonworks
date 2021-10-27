json.extract! type_material, :id, :protonym_id, :collection_object_id, :type_type, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at
json.partial! '/shared/data/all/metadata', object: type_material

json.original_combination full_original_taxon_name_tag(type_material.protonym)

if extend_response_with('collection_object')
  json.collection_object do
    json.partial! '/collection_objects/attributes', collection_object: type_material.collection_object
  end
end
