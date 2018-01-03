json.extract! type_material, :id, :protonym_id, :biological_object_id, :type_type, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at

json.partial! '/shared/data/all/metadata', object: type_material 

json.collection_object do 
  json.partial! '/collection_objects/attributes', collection_object: type_material.material
end

if type_material.roles.any?
  json.type_designator_roles do
    json.array! type_material.type_designator_roles.each do |role|
      json.extract! role, :id, :position
      json.person do
        json.partial! '/people/attributes', person: role.person 
      end
    end
  end
end 

