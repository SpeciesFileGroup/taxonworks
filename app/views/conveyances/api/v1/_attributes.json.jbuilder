json.extract! conveyance, :id, :sound_id, :conveyance_object_id, :conveyance_object_type, :start_time, :end_time, :project_id, :created_by_id, :updated_by_id, :created_at, :updated_at

if extend_response_with('sound')
  json.sound do
    json.partial! '/sounds/api/v1/attributes', sound: conveyance.sound
  end
end

if extend_response_with('notes')
  json.notes conveyance.notes.each do |n|
    json.text n.text
  end
end

if extend_response_with('citations') && conveyance.has_citations?
  json.citations do
    json.array! conveyance.citations do |citation|
      json.partial! '/citations/api/v1/attributes', citation: citation, extensions: false
      json.source do
        json.partial! '/sources/api/v1/base_attributes', source: citation.source
      end
    end
  end
end