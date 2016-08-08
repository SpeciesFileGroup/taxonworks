json.array!(@observations) do |observation|
  json.extract! observation, :id, :descriptor_id, :otu_id, :collection_object_id, :character_state_id, :frequency, :continuous_value, :continuous_unit, :sample_n, :sample_min, :sample_max, :sample_median, :sample_mean, :sample_units, :sample, :sample_standard_error, :presence, :description, :cached, :cached_column_label, :cached_row_label, :created_by_id, :updated_by_id, :project_id
  json.url observation_url(observation, format: :json)
end
