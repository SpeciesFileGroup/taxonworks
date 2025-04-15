json.extract! sound, :id, :name, :project_id, :created_by_id, :updated_by_id, :sound_file, :created_at, :updated_at

json.sound_file short_url(url_for(sound.sound_file))

json.metadata sound_metadata(sound)

if extend_response_with('conveyances')
  json.conveyances sound.conveyances do |c|
    json.extract! c,:id, :conveyance_object_id, :conveyance_object_type, :start_time, :end_time
    json.label label_for_conveyance(c)
  end
end

if extend_response_with('attribution')
  json.attribution do
    json.label label_for_attribution(sound.attribution)
  end
end
