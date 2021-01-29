json.extract! note, :id, :text, :note_object_attribute, :note_object_id, :note_object_type, :created_by_id, :updated_by_id, :project_id

json.note_object do
  json.global_id note.note_object.to_global_id.to_s
end
