json.array!(@confidences) do |confidence|
  json.extract! confidence, :id, :confidence_object, :position, :created_by_id, :updated_by_id, :project_id
  json.url confidence_url(confidence, format: :json)
end
