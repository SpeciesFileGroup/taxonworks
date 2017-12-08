json.extract! sequence, :id, :sequence, :sequence_type, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at
json.object_tag sequence_tag(sequence)
json.url sequence_url(sequence, format: :json)
json.global_id sequence.to_global_id.to_s
json.type 'Sequence'
