json.array!(@collection_object_observations) do |collection_object_observation|
  json.extract! collection_object_observation, :id, :data, :metadata, :project_id, :created_by_id, :updated_by_id
  json.url collection_object_observation_url(collection_object_observation, format: :json)
end
