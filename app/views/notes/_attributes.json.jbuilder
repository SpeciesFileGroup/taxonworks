json.extract! note, :id, :text, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at
json.object_tag note_tag(note)
json.url note_url(note, format: :json)

