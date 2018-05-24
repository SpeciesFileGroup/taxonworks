json.extract! alternate_value, :id, :type, :alternate_value_object_type, :alternate_value_object_id, :alternate_value_object_attribute, :language_id, :value, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at

json.partial! '/shared/data/all/metadata', object: alternate_value
json.annotated_object_global_id alternate_value.alternate_value_object.to_global_id.to_s
json.annotated_object_url url_for(alternate_value.alternate_value_object)

json.url alternate_value_url(alternate_value, format: :json)

