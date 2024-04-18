json.extract! field_occurrence, :id, :total, :collecting_event_id, :is_absent, :created_at, :updated_at

json.partial! '/shared/data/all/metadata', object: field_occurrence 

if extend_response_with('taxon_determinations')
  json.taxon_determination_id field_occurrence.taxon_determinations.pluck(:id)
end

# json.url field_occurrence_url(field_occurrence, format: :json)
