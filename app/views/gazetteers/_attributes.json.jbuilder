json.extract! gazetteer, :id, :name, :project_id,
  :iso_3166_a2, :iso_3166_a3,
  :created_by_id, :updated_by_id, :created_at, :updated_at

json.partial!('/shared/data/all/metadata', object: gazetteer)

json.has_shape true
json.data_origin gazetteer.data_origin

if embed_response_with('shape')
  json.shape gazetteer.to_geo_json_feature
end

if extend_response_with('shape_type')
  json.shape_type do
    json.name 'Gazetteer'
  end
end
