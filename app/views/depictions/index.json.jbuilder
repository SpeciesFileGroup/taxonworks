json.array!(@depictions) do |depiction|
  json.extract! depiction, :id, :depiction_object, :image_id, :created_by_id, :updated_by_id, :project_id
  json.url depiction_url(depiction, format: :json)
end
