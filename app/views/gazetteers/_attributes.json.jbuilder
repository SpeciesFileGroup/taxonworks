json.extract! gazetteer, :id, :name, :parent_id, :project_id,
  :iso_3166_a2, :iso_3166_a3,
  :created_by_id, :updated_by_id, :created_at, :updated_at

  # TODO how does embed work?
  #if embed_response_with('shape')
    json.shape gazetteer.to_geo_json_feature
  #end

  json.partial!('/shared/data/all/metadata', object: gazetteer)
