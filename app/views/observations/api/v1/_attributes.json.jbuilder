json.extract! observation, :id, :descriptor_id, :otu_id, :collection_object_id, :character_state_id, :frequency,
:continuous_value, :continuous_unit,
:sample_n, :sample_min, :sample_max, :sample_median, :sample_mean, :sample_units, :sample_standard_error, :sample_standard_deviation,
:presence, :description, :cached, :cached_column_label, :cached_row_label, :type,
:created_by_id, :updated_by_id, :project_id, :created_at, :updated_at
json.partial! '/shared/data/all/metadata', object: observation
json.label observation_cell_tag(observation)

if observation.type == 'Observation::Qualitative'
  if extend_response_with('character_state')
    json.character_state do
      json.partial! '/shared/data/all/metadata', object: observation.character_state
      json.name observation.character_state.name
    end
  end
end

if extend_response_with('depictions')
  if observation.depictions.any?
    json.depictions do
      json.array! observation.depictions.each do |depiction|
        #TODO: Not an API endpoint
        json.partial! '/depictions/attributes', depiction: depiction
      end
    end
  end
end
