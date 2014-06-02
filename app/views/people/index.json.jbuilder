json.array!(@people) do |person|
  json.extract! person, :id, :type, :last_name, :first_name, :suffix, :prefix, :created_by_id, :updated_by_id
  json.url person_url(person, format: :json)
end
