json.extract! origin_relationship, :id,
:old_object_id, :old_object_type,
:new_object_id, :new_object_type,
:position,
:created_by_id, :updated_by_id, :project_id, :created_at, :updated_at,
:old_object, :new_object

json.old_object_object_tag object_tag(origin_relationship.old_object)
json.new_object_object_tag object_tag(origin_relationship.new_object)

json.partial! '/shared/data/all/metadata', object: origin_relationship

if extend_response_with('global_ids')
  json.old_object_global_id origin_relationship.old_object.to_global_id.to_s
  json.new_object_global_id origin_relationship.new_object.to_global_id.to_s
end