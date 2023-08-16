json.extract! observation, :id, :descriptor_id, :observation_object_id, :observation_object_type, :character_state_id, :frequency,
  :continuous_value, :continuous_unit,
  :sample_n, :sample_min, :sample_max, :sample_median, :sample_mean, :sample_units, :sample_standard_error, :sample_standard_deviation,
  :presence, :description, :cached, :cached_column_label, :cached_row_label, :type,
  :year_made, :month_made, :day_made,
  :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at

json.type_label observation_type_label(observation)

json.time_made observation.time_made&.to_formatted_s(:hour_minutes_seconds)

json.partial! '/shared/data/all/metadata', object: observation

if extend_response_with('observation_object')
  json.observation_object do
    json.object_tag object_tag(observation.observation_object) 
  end
end

if extend_response_with('depictions')
  if observation.depictions.any?
    json.depictions do
      json.array! observation.depictions.each do |depiction|
        json.partial! '/depictions/attributes', depiction: depiction
      end
    end
  end
end
