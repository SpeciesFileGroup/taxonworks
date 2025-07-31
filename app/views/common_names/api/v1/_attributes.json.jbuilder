json.extract! common_name, :id, :name, :geographic_area_id, :otu_id, :language_id, :start_year, :end_year, :created_at, :updated_at

json.language label_for_language(common_name.language)

if extend_response_with('otu')
  json.otu do
    json.partial! '/otus/api/v1/attributes', otu: common_name.otu
  end
end

if common_name.geographic_area
  json.geographic_area do
    json.name common_name.geographic_area.name
  end
end
