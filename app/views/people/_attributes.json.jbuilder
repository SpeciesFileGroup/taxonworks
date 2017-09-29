json.extract! person, :id, :type, :last_name, :first_name, :suffix, :prefix, :created_by_id, :updated_by_id, :created_at, :updated_at
json.object_tag person_tag(person)
json.url person_url(person, format: :json)
json.global_id person.to_global_id.to_s

