json.extract! alternate_value, :id, :type, :alternate_value_object_attribute, :language_id, :value, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at
json.object_tag alternate_value_tag(alternate_value)
json.alternate_value_object_global_id alternate_value.alternate_value_object.to_global_id.to_s
json.url alternate_value_url(alternate_value, format: :json)

