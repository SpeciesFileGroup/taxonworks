json.array!(@people) do |person|
  json.partial! '/people/base_attributes', person: person
  json.use_count @project_use_counts[person.id] || 0
end
