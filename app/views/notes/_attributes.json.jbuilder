json.extract! note, :id, :text, :note_object_id, :note_object_type, :note_object_attribute, :created_by_id, :updated_by_id, :project_id
json.object_tag note_tag(note)
json.url note_url(note, format: :json)

