json.array!(@collection_profiles) do |collection_profile|
  json.extract! collection_profile, :id, :container_id, :otu_id, :conservation_status, :processing_state, :container_condition, :condition_of_labels, :identification_level, :arrangement_level, :data_quality, :computerization_level, :number_of_collection_objects, :number_of_containers, :created_by_id, :updated_by_id, :project_id, :collection_type
  json.url collection_profile_url(collection_profile, format: :json)
end
