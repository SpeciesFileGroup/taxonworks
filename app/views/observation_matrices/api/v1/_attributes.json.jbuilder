json.extract! observation_matrix, :id, :name, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at
json.partial! '/shared/data/all/metadata', object: observation_matrix 
json.is_media_matrix observation_matrix.is_media_matrix?

if extend_response_with('rows')
  json.rows(observation_matrix.observation_matrix_rows.order(:position)) do |r|
    json.partial! '/shared/data/all/metadata', object: r, extensions: false 

    json.row_object do
      json.partial! '/shared/data/all/metadata', object: r.row_object, extensions: false 
    end
  end
end

if extend_response_with('columns')
  json.columns(observation_matrix.observation_matrix_columns.order(:position)) do |c|
    json.partial! '/shared/data/all/metadata', object: c, extensions: false 

    json.descriptor do
      json.partial! '/shared/data/all/metadata', object: c.descriptor, extensions: false 
    end
  end
end
