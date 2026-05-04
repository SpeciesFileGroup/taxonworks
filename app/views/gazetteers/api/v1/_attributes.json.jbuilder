json.extract! gazetteer, :id, :name, :iso_3166_a2, :iso_3166_a3,
  :created_at, :updated_at

if extend_response_with('geo_json')
  json.geo_json gazeteer.to_geo_json_feature
end

if extend_response_with('notes')
  json.notes gazetteer.notes.each do |n|
    json.text n.text
  end
end
