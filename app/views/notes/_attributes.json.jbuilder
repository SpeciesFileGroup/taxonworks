json.extract! note, :id, :text, :note_object_id, :note_object_type, :note_object_attribute, :created_by_id, :updated_by_id, :created_at, :updated_at, :project_id

json.partial! '/shared/data/all/metadata', object: note 

json.annotated_object do
  json.partial! '/shared/data/all/metadata', object: metamorphosize_if(note.note_object) 
end

