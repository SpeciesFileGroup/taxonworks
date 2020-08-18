json.extract! role, :id, :person_id, :role_object_id, :role_object_type, :position, :project_id, :created_by_id, :updated_by_id, :created_at, :updated_at

# do not have  `role_path()`, which prevents us from using:
# json.partial! '/shared/data/all/metadata', role: role, klass: 'Role',
# so we unDRY the code here

json.role_object_tag role_object_tag(role)
json.global_id role.to_global_id.to_s
json.in_project role_in_project?(role)
json.type 'Role'
json.url url_for(only_path: false, format: :json) # radial annotator metamorphosize_if(role)) # , 


