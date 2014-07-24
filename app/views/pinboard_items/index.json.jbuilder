json.array!(@pinboard_items) do |pinboard_item|
  json.extract! pinboard_item, :id, :pinned_object_id, :pinned_object_type, :user_id, :project_id, :position, :is_inserted, :is_cross_project, :inserted_count, :created_by_id, :updated_by_id
  json.url pinboard_item_url(pinboard_item, format: :json)
end
