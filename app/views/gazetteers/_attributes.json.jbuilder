json.extract! gazetteer, :id, :name, :project_id,
  :iso_3166_a2, :iso_3166_a3,
  :created_by_id, :updated_by_id, :created_at, :updated_at

  json.shape gazetteer.to_geo_json_feature

  json.partial!('/shared/data/all/metadata', object: gazetteer)
