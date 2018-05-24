json.extract! alternate_value, :id, :type, :alternate_value_object_type, :alternate_value_object_id, :alternate_value_object_attribute, :language_id, :value, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at

json.partial! '/shared/data/all/metadata', object: alternate_value

json.annotated_object do
  json.partial! '/shared/data/all/metadata', object: metamorphosize_if(alternate_value.alternate_value_object) 
end
