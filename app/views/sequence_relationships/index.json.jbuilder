json.array!(@sequence_relationships) do |sequence_relationship|
  json.extract! sequence_relationship, :id, :subject_sequence, :type, :object_sequence, :created_by_id, :updated_by_id, :project_id
  json.url sequence_relationship_url(sequence_relationship, format: :json)
end
