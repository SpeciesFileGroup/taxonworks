json.array!(@type_materials) do |type_material|
  json.extract! type_material, :id, :protonym_id, :biological_object_id, :type_type, :source_id, :created_by_id, :updated_by_id, :project_id
  json.url type_material_url(type_material, format: :json)
end
