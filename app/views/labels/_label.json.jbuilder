json.extract! label, :id, :text, :total, :style, :label_object_id, :label_object_type, :is_copy_edited, :is_printed, :project_id, :created_at, :updated_at

json.url label_url(label, format: :json)
