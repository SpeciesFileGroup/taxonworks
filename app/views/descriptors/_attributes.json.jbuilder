json.extract! descriptor, :id, :name, :short_name, :description, :default_unit,
  :type, :position, :description_name, :key_name, 
  :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at

json.partial! '/shared/data/all/metadata', object: descriptor, klass: descriptor.type 

if descriptor.qualitative?
  json.character_states do 
    json.array! descriptor.character_states do |character_state|
      json.partial! '/character_states/attributes', character_state: character_state
    end
  end
end

