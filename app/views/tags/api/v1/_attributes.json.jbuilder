json.extract! tag, :id, :tag_object_type, :tag_object_attribute, :tag_object_id, :keyword_id, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at
json.tag_object_global_id tag.tag_object.to_global_id.to_s

json.keyword do
  json.name tag.keyword.name
end
