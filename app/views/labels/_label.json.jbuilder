json.extract! label, :id, :total, :style, :text, :type, :label_object_id, :label_object_type, :is_copy_edited, :is_printed, :project_id, :created_at, :created_by_id, :updated_at
json.updated_by label.updater.name
json.url label_url(label, format: :json)
json.on object_tag(label.label_object)
json.label taxonworks_label_tag(label)
