json.extract! observation, :id, :descriptor_id, :observation_object_id, :observation_object_type, :character_state_id, :frequency,
:continuous_value, :continuous_unit,
:sample_n, :sample_min, :sample_max, :sample_median, :sample_mean, :sample_units, :sample_standard_error, :sample_standard_deviation,
:presence, :description, :cached, :cached_column_label, :cached_row_label, :type,
:created_by_id, :updated_by_id, :project_id, :created_at, :updated_at

json.label observation_cell_tag(observation)

if observation.type == 'Observation::Qualitative'
  if extend_response_with('character_state')
    json.character_state do
      json.label observation.character_state.label
      json.name observation.character_state.name
    end
  end
end

if extend_response_with('descriptor')
  json.descriptor do
    json.name observation.descriptor.name
    json.description observation.descriptor.description
  end
end

if extend_response_with('depictions')
  if observation.depictions.any?
    json.depictions do
      json.array! observation.depictions.each do |depiction|
        json.partial! '/depictions/api/v1/attributes', depiction: depiction
      end
    end
  end
end
