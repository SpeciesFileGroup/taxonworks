json.array!(@notes) do |note|
  json.extract! note, :id, :text, :note_object_id, :note_object_type, :note_object_attribute, :created_by_id, :updated_by_id, :project_id
  json.url note_url(note, format: :json)
end
