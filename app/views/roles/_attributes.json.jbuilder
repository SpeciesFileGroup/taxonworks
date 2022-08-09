json.extract! role, :id, :person_id, :role_object_id, :role_object_type, :type, :position, :project_id, :created_by_id, :updated_by_id, :created_at, :updated_at
json.partial! '/shared/data/all/metadata', object: role, url_base: 'role'

json.in_project Role.exists?(project_id: sessions_current_project_id, id: role.id)

if extend_response_with('role_object')
  json.role_object do
    json.partial! '/shared/data/all/metadata', object: role.role_object, extensions: false
  end
end
