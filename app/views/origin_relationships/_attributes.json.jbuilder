json.extract! origin_relationship, :id, :old_object, :new_object, :position, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at

json.old_object_object_tag object_tag(origin_relationship.old_object)
json.new_object_object_tag object_tag(origin_relationship.new_object)

json.partial! '/shared/data/all/metadata', object: origin_relationship 
