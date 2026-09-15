json.extract! alternate_value, :id, :type, :value,
  :alternate_value_object_id, :alternate_value_object_type, :alternate_value_object_attribute,
  :language_id, :project_id, :created_at, :updated_at

json.alternate_value_object_global_id alternate_value.alternate_value_object.to_global_id.to_s

if extend_response_with('annotated_object')
  json.annotated_object do
    json.partial! '/shared/data/all/metadata',
      object: metamorphosize_if(alternate_value.alternate_value_object), extensions: false
  end
end

if extend_response_with('language') && alternate_value.language
  json.language do
    json.extract! alternate_value.language, :id, :english_name, :alpha_2, :alpha_3_bibliographic
  end
end
