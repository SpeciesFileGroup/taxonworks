json.array!(@alternate_values) do |alternate_value|
  json.extract! alternate_value, :id, :value, :type, :language_id, :alternate_object_type, :alternate_object_id, :alternate_object_attribute, :created_by_id, :updated_by_id
  json.url alternate_value_url(alternate_value, format: :json)
end
