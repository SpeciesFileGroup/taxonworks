json.extract! descriptor, :id, :name, :short_name, :description, :type, :position, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at
json.object_tag descriptor_tag(descriptor)
json.url descriptor_url(descriptor, format: :json)

if descriptor.qualitative?
  json.character_states do 
    json.array! descriptor.character_states do |character_state|
      json.partial! '/character_states/attributes', character_state: character_state
    end
  end
end

