json.extract! label, :id, :text, :total, :style, :label_object_id, :label_object_type, :is_copy_edited, :is_printed, :project_id, :created_at, :created_by_id, :updated_at
json.updated_by username_by_id(label.updated_by_id)
json.url label_url(label, format: :json)
