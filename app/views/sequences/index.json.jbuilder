json.array!(@sequences) do |sequence|
  json.extract! sequence, :id, :sequence, :sequence_type, :created_by_id, :updated_by_id, :project_id
  json.url sequence_url(sequence, format: :json)
end
