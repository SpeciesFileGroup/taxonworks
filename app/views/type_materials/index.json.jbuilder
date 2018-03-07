json.array!(@type_materials) do |type_material|
  json.partial! 'attributes', type_material: type_material
end
