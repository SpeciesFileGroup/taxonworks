json.extract! sound, :id, :name, :project_id, :created_by_id, :updated_by_id, :sound_file, :created_at, :updated_at
json.partial! '/shared/data/all/metadata', object: sound

json.sound_file url_for(sound.sound_file)

json.metadata sound_metadata(sound)

if extend_response_with('attribution')
  json.attribution do
    if sound.attribution
      json.partial! '/attributions/attributes', attribution: sound.attribution
    else
      json.not_provided true
    end
  end
end
