json.array!(@data_attributes) do |data_attribute|
  json.extract! data_attribute, :id, :type, :attribute_subject_id, :attribute_subject_type, :controlled_vocabulary_term_id, :import_predicate, :value, :created_by_id, :updated_by_id, :project_id
  json.url data_attribute_url(data_attribute, format: :json)
end
