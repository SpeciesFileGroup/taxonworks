json.extract! observation, :id, :descriptor_id, :otu_id, :collection_object_id, :character_state_id, :frequency,
  :continuous_value, :continuous_unit, 
  :sample_n, :sample_min, :sample_max, :sample_median, :sample_mean, :sample_units, :sample_standard_error, :sample_standard_deviation,
  :presence, :description, :cached, :cached_column_label, :cached_row_label, :type,
  :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at
json.partial! '/shared/data/all/metadata', object: observation 

if observation.depictions.any?
  json.depictions do
    json.array! observation.depictions.each do |depiction|
      json.partial! '/depictions/attributes', depiction: depiction
    end
  end
end
