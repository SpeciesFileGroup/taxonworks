json.extract! character_state, :id, :name, :description_name, :key_name, :label, :descriptor_id, :position, 
  :project_id, :created_by_id, :updated_by_id, :created_at, :updated_at

json.partial! '/shared/data/all/metadata', object: character_state

