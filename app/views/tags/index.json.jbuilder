json.array!(@tags) do |tag|
  json.extract! tag, :id, :keyword_id, :tag_object_id, :tag_object_type, :tag_object_attribute, :created_by_id, :updated_by_id, :project_id, :position
  json.url tag_url(tag, format: :json)
end
