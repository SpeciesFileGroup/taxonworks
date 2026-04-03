json.extract! observation_matrix, :id, :name, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at
json.partial! '/shared/data/all/metadata', object: observation_matrix 
json.is_media_matrix observation_matrix.is_media_matrix?

if extend_response_with('rows')
  json.rows(observation_matrix.observation_matrix_rows.order(:position)) do |r|
    json.partial! '/shared/data/all/metadata', object: r, extensions: false 

    json.observation_object do
      json.partial! '/shared/data/all/metadata', object: r.observation_object, extensions: false 
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

if extend_response_with('notes')
  json.notes observation_matrix.notes.each do |n|
    json.text n.text
  end
end

if extend_response_with('citations') && observation_matrix.has_citations?
  json.citations do
    json.array! observation_matrix.citations do |citation|
      json.partial! '/citations/api/v1/attributes', citation: citation, extensions: false
      json.source do
        json.extract! citation.source, :id, :cached, :year
      end
    end
  end
end
