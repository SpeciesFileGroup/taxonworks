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

if extend_response_with('notes')
  json.notes common_name.notes.each do |n|
    json.text n.text
  end
end

if extend_response_with('citations') && common_name.has_citations?
  json.citations do
    json.array! common_name.citations do |citation|
      json.partial! '/citations/api/v1/attributes', citation: citation, extensions: false
      json.source do
        json.partial! '/sources/api/v1/base_attributes', source: citation.source
      end
    end
  end
end
