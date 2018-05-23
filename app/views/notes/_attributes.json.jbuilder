json.extract! note, :id, :text, :note_object_id, :note_object_type, :note_object_attribute, :created_by_id, :updated_by_id, :project_id

json.partial! '/shared/data/all/metadata', object: note 
json.annotated_object_global_id note.note_object.to_global_id.to_s

