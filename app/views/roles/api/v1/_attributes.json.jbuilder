json.extract! role, :id, :person_id, :role_object_id, :role_object_type, :position, :type, :created_by_id, :updated_by_id, :created_at, :updated_at

json.global_id role.to_global_id.to_s

# TODO this is not used
if params[:verbose_roles] == 'true'
  json.role_object_tag role_object_tag(role)
end
